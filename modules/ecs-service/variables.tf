variable "name_prefix" {
  description = "Prefix used to name service resources"
  type        = string
}

variable "service_name" {
  description = "Name of this service, used in resource names and log group"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster this service runs on"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the service security group and target group are created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used to place the ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the shared ALB, allowed to reach this service"
  type        = string
  default     = null
}

variable "listener_arn" {
  description = "ARN of the shared ALB HTTP listener to attach this service's routing rule to"
  type        = string
  default     = null
}

variable "path_pattern" {
  description = "Path patterns routed to this service on the shared listener"
  type        = list(string)
  default     = []
}

variable "priority" {
  description = "Listener rule priority, must be unique across services sharing the listener"
  type        = number
  default     = null
}

variable "enable_load_balancer" {
  description = "Whether this service receives traffic through the shared ALB"
  type        = bool
  default     = true
}

variable "image" {
  description = "Container image (ECR repository URL plus tag) to run"
  type        = string
}

variable "container_name" {
  description = "Name of the container in the task definition"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "container_command" {
  description = "Optional command that replaces the image command"
  type        = list(string)
  default     = []
}

variable "cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of task instances to run"
  type        = number
  default     = 1
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 3
}

variable "health_check_path" {
  description = "Path used by the target group health check"
  type        = string
  default     = "/"
}

variable "env_vars" {
  description = "Environment variables injected into the container"
  type        = map(string)
  default     = {}
}
