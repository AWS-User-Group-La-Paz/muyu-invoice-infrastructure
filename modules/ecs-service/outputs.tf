output "service_name" {
  value = aws_ecs_service.this.name
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}
