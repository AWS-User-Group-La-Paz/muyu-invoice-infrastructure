# Creates the shared ECS cluster, public load balancer, and listeners.
module "cluster" {
  source = "./modules/ecs-cluster"

  name_prefix       = var.name_prefix
  vpc_id            = aws_vpc.main.id
  public_subnet_ids = [aws_subnet.public1.id, aws_subnet.public2.id]
  certificate_arn   = aws_acm_certificate_validation.domain.certificate_arn
}
