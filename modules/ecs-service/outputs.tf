output "service_name" {
  value = aws_ecs_service.this.name
}

output "target_group_arn" {
  value = try(aws_lb_target_group.this[0].arn, null)
}

output "target_group_arn_suffix" {
  value = try(aws_lb_target_group.this[0].arn_suffix, null)
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "task_role_name" {
  value = aws_iam_role.task.name
}
