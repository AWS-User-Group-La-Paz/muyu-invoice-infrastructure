variable "name_prefix" {
  description = "Prefix used to name cluster and load balancer resources"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ALB and its security group are created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used to place the Application Load Balancer"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used by the HTTPS listener"
  type        = string
}
