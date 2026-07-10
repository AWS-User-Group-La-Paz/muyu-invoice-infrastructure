module "invoice_service" {
  source = "./modules/ecs-service"

  name_prefix           = var.name_prefix
  service_name          = "invoice"
  cluster_id            = module.cluster.cluster_id
  desired_count         = 1
  vpc_id                = aws_vpc.main.id
  private_subnet_ids    = [aws_subnet.private1.id, aws_subnet.private2.id]
  alb_security_group_id = module.cluster.alb_security_group_id
  listener_arn          = module.cluster.http_listener_arn
  path_pattern          = ["/*"]
  health_check_path     = "/health"
  priority              = 100
  image                 = "${aws_ecr_repository.main.repository_url}:${var.image_tag}"
  # image                 = "public.ecr.aws/q1v8x8d9/muyu:20260702"
  container_name = "invoice"
  container_port = var.container_port

  env_vars = {
    DATABASE_URL = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.main.address}:5432/${var.db_name}?sslmode=no-verify"
  }
}
