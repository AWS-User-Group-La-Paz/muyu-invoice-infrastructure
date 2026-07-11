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
  listener_arn          = module.cluster.http_listener_arn
  path_pattern          = ["/*"]
  health_check_path     = "/health"
  priority              = 100
  image                 = "${aws_ecr_repository.main.repository_url}:${var.image_tag}"
  container_name        = "invoice"
  container_port        = var.container_port

  env_vars = {
    NODE_ENV      = "production"
    AWS_REGION    = var.aws_region
    SQS_QUEUE_URL = aws_sqs_queue.invoice_pdf_jobs.url
    S3_BUCKET     = aws_s3_bucket.invoice_pdfs.bucket
    DATABASE_URL  = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.main.address}:5432/${var.db_name}?sslmode=no-verify"
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
  image                = "${aws_ecr_repository.main.repository_url}:${var.image_tag}"
  container_name       = "invoice-worker"
  container_port       = var.container_port
  container_command    = ["node", "src/worker.js"]

  env_vars = {
    NODE_ENV      = "production"
    AWS_REGION    = var.aws_region
    SQS_QUEUE_URL = aws_sqs_queue.invoice_pdf_jobs.url
    S3_BUCKET     = aws_s3_bucket.invoice_pdfs.bucket
    EMAIL_FROM    = var.email_from
    DATABASE_URL  = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.main.address}:5432/${var.db_name}?sslmode=no-verify"
  }
}
