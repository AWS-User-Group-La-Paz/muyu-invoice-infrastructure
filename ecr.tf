resource "aws_ecr_repository" "main" {
  name                 = ${var.name_prefix}
  image_tag_mutability = "IMMUTABLE"

  tags = {
    Name = var.name_prefix
  }
}
