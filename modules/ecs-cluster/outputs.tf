output "cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "http_listener_arn" {
  value = aws_lb_listener.http.arn
}
