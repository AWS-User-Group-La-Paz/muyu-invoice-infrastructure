# Preserves existing web resources after making load balancing optional.
moved {
  from = aws_lb_target_group.this
  to   = aws_lb_target_group.this[0]
}

moved {
  from = aws_lb_listener_rule.this
  to   = aws_lb_listener_rule.this[0]
}

# Lets ECS download container images and send container logs to CloudWatch.
resource "aws_iam_role" "execution" {
  name = "${var.name_prefix}-${var.service_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attaches AWS-managed image-pull and log-publishing permissions to the execution role.
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Lets ECS inject the collector configuration and Grafana token into the sidecar.
resource "aws_iam_role_policy" "collector_ssm" {
  count = var.otel_collector == null ? 0 : 1

  name = "${var.name_prefix}-${var.service_name}-collector-ssm-policy"
  role = aws_iam_role.execution.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameters"]
      Resource = [var.otel_collector.config_parameter_arn, var.otel_collector.token_parameter_arn]
    }]
  })
}

# Defines permissions available to code running inside the container.
resource "aws_iam_role" "task" {
  name = "${var.name_prefix}-${var.service_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Retains the service's container logs in CloudWatch for a limited period.
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name_prefix}-${var.service_name}"
  retention_in_days = var.log_retention_days
}

# Allows only the shared ALB to connect to this service's container port.
resource "aws_security_group" "this" {
  name   = "${var.name_prefix}-${var.service_name}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.enable_load_balancer ? [1] : []

    content {
      from_port       = var.container_port
      to_port         = var.container_port
      protocol        = "tcp"
      security_groups = [var.alb_security_group_id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-${var.service_name}-sg"
  }
}

# Registers private Fargate task IP addresses as load-balancer targets.
resource "aws_lb_target_group" "this" {
  count = var.enable_load_balancer ? 1 : 0

  name        = "${var.name_prefix}-${var.service_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = var.health_check_path
  }

  tags = {
    Name = "${var.name_prefix}-${var.service_name}-tg"
  }
}

# Routes this service's URL paths from the shared listener to its target group.
resource "aws_lb_listener_rule" "this" {
  count = var.enable_load_balancer ? 1 : 0

  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    path_pattern {
      values = var.path_pattern
    }
  }
}

# Describes the Fargate container image, resources, environment, and logging.
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-${var.service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode(concat([
    merge({
      name      = var.container_name
      image     = var.image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [for k, v in var.env_vars : { name = k, value = v }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = var.service_name
        }
      }
      }, length(var.container_command) > 0 ? { command = var.container_command } : {}, var.otel_collector == null ? {} : {
      dependsOn = [{
        containerName = "otel-collector"
        condition     = "START"
      }]
    })
    ], var.otel_collector == null ? [] : [{
      name      = "otel-collector"
      image     = var.otel_collector.image
      essential = false
      command   = ["--config=env:OTELCOL_CONFIG_CONTENT"]

      environment = [
        { name = "GRAFANA_OTLP_ENDPOINT", value = var.otel_collector.grafana_otlp_endpoint },
        { name = "GRAFANA_OTLP_USERNAME", value = var.otel_collector.grafana_otlp_username },
        { name = "OTEL_SERVICE_NAME", value = var.otel_collector.otel_service_name },
        { name = "METRICS_ENDPOINT", value = var.otel_collector.metrics_endpoint },
      ]

      secrets = [
        { name = "OTELCOL_CONFIG_CONTENT", valueFrom = var.otel_collector.config_parameter_arn },
        { name = "GRAFANA_OTLP_TOKEN", valueFrom = var.otel_collector.token_parameter_arn },
      ]
  }]))
}

# Keeps the requested number of Fargate tasks running behind the target group.
resource "aws_ecs_service" "this" {
  name            = "${var.name_prefix}-${var.service_name}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.this.id]
  }

  dynamic "load_balancer" {
    for_each = var.enable_load_balancer ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  depends_on = [aws_lb_listener_rule.this, aws_iam_role_policy.collector_ssm]
}

# Reads the configured AWS region for the CloudWatch log driver.
data "aws_region" "current" {}
