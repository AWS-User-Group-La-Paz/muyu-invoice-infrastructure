# Useful identifiers printed after terraform apply.
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "nat_public_ip" {
  value = aws_eip.nat.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "alb_dns_name" {
  value = "https://${var.domain}"
}

output "name_servers" {
  value = {
    (split(".", var.domain)[0]) = aws_route53_zone.domain.name_servers
  }
}
