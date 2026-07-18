# Deploys the invoice container as private Fargate tasks behind the shared ALB.
module "invoice_service" {
  source = "./modules/ecs-service"

  name_prefix           = var.name_prefix
  service_name          = "invoice"
  cluster_id            = module.cluster.cluster_id
  desired_count         = var.invoice_desired_count
  vpc_id                = aws_vpc.main.id
  private_subnet_ids    = [aws_subnet.private1.id, aws_subnet.private2.id]
  alb_security_group_id = module.cluster.alb_security_group_id
  listener_arn          = module.cluster.https_listener_arn
  path_pattern          = ["/*"]
  health_check_path     = "/health"
  priority              = 100
  image                 = "ghcr.io/aws-user-group-la-paz/muyu-invoice-generator:${var.image_tag}"
  container_name        = "invoice"
  container_port        = var.container_port

  otel_collector = {
    image                 = var.otel_collector_image
    grafana_otlp_endpoint = var.grafana_otlp_endpoint
    grafana_otlp_username = var.grafana_otlp_username
    config_parameter_arn  = aws_ssm_parameter.grafana_collector_config.arn
    token_parameter_arn   = aws_ssm_parameter.grafana_otlp_token.arn
    otel_service_name     = "muyu-web"
    metrics_endpoint      = "127.0.0.1:${var.container_port}"
  }

  env_vars = {
    NODE_ENV                 = "production"
    AWS_REGION               = var.aws_region
    OTEL_SERVICE_NAME        = "muyu-web"
    OTEL_RESOURCE_ATTRIBUTES = "deployment.environment=workshop,service.version=${var.image_tag},cloud.provider=aws,cloud.region=${var.aws_region}"
    SQS_QUEUE_URL            = aws_sqs_queue.invoice_pdf_jobs.url
    S3_BUCKET                = aws_s3_bucket.invoice_pdfs.bucket
    DATABASE_URL             = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.main.address}:5432/${var.db_name}?sslmode=no-verify"
  }
}

# Processes queued invoices without receiving inbound network traffic.
module "invoice_worker" {
  source = "./modules/ecs-service"

  name_prefix          = var.name_prefix
  service_name         = "invoice-worker"
  cluster_id           = module.cluster.cluster_id
  desired_count        = 1
  vpc_id               = aws_vpc.main.id
  private_subnet_ids   = [aws_subnet.private1.id, aws_subnet.private2.id]
  enable_load_balancer = false
  image                = "ghcr.io/aws-user-group-la-paz/muyu-invoice-generator:${var.image_tag}"
  container_name       = "invoice-worker"
  container_port       = var.container_port
  container_command    = ["node", "src/worker.js"]

  otel_collector = {
    image                 = var.otel_collector_image
    grafana_otlp_endpoint = var.grafana_otlp_endpoint
    grafana_otlp_username = var.grafana_otlp_username
    config_parameter_arn  = aws_ssm_parameter.grafana_collector_config.arn
    token_parameter_arn   = aws_ssm_parameter.grafana_otlp_token.arn
    otel_service_name     = "muyu-worker"
    metrics_endpoint      = "127.0.0.1:9464"
  }

  env_vars = {
    NODE_ENV                 = "production"
    AWS_REGION               = var.aws_region
    OTEL_SERVICE_NAME        = "muyu-worker"
    OTEL_RESOURCE_ATTRIBUTES = "deployment.environment=workshop,service.version=${var.image_tag},cloud.provider=aws,cloud.region=${var.aws_region}"
    SQS_QUEUE_URL            = aws_sqs_queue.invoice_pdf_jobs.url
    S3_BUCKET                = aws_s3_bucket.invoice_pdfs.bucket
    EMAIL_FROM               = var.email_from
    DATABASE_URL             = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.main.address}:5432/${var.db_name}?sslmode=no-verify"
  }
}
