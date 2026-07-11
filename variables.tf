# Selects the AWS region where every resource in this deployment is created.
variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region to use for all resources"
  type        = string
}

# Prefixes resource names so related AWS resources are easy to identify.
variable "name_prefix" {
  default     = "muyu"
  description = "Prefix used to name teaching network resources"
  type        = string
}

# Selects the first Availability Zone for subnet placement.
variable "availability_zone1" {
  default     = "us-east-1a"
  description = "The first Availability Zone for subnet placement"
  type        = string
}

# Selects the second Availability Zone for subnet placement.
variable "availability_zone2" {
  default     = "us-east-1b"
  description = "The second Availability Zone for subnet placement"
  type        = string
}

# Defines the private IP address range available to the whole VPC.
variable "vpc_cidr" {
  default     = "10.10.0.0/16"
  description = "The CIDR block to use in the VPC"
  type        = string
}

# Defines the first public subnet, used by internet-facing resources such as the ALB.
variable "subnet_public1_cidr" {
  default     = "10.10.10.0/24"
  description = "The CIDR block to use in the public subnet 1"
  type        = string
}

# Defines the second public subnet in another Availability Zone for the ALB.
variable "subnet_public2_cidr" {
  default     = "10.10.11.0/24"
  description = "The CIDR block to use in the public subnet 2"
  type        = string
}

# Defines the first private subnet, used by ECS tasks and the database.
variable "subnet_private1_cidr" {
  default     = "10.10.20.0/24"
  description = "The CIDR block to use in the private subnet 1"
  type        = string
}

# Defines the second private subnet in another Availability Zone for ECS and RDS.
variable "subnet_private2_cidr" {
  default     = "10.10.21.0/24"
  description = "The CIDR block to use in the private subnet 2"
  type        = string
}

# Sets the port where the invoice container accepts requests from the ALB.
variable "container_port" {
  default     = 3000
  description = "Port the invoice service container listens on"
  type        = number
}

# Sets the number of invoice service tasks ECS keeps running.
variable "invoice_desired_count" {
  default     = 1
  description = "Number of invoice service tasks to run"
  type        = number
}

# Selects the container image tag deployed to the ECS service.
variable "image_tag" {
  description = "Tag of the container image to run as the invoice service"
  type        = string
}

# Selects the verified SES address used to send generated invoices.
variable "email_from" {
  description = "Verified SES sender used by the invoice worker"
  type        = string
}

# Chooses the RDS instance size, which controls database cost and capacity.
variable "db_instance_class" {
  default     = "db.t3.micro"
  description = "Instance class for the RDS PostgreSQL server"
  type        = string
}

# Sets the name of the database created when RDS is first provisioned.
variable "db_name" {
  default     = "muyu"
  description = "Name of the initial database created on the RDS instance"
  type        = string
}

# Sets the PostgreSQL administrator account created by RDS.
variable "db_username" {
  default     = "muyu_admin"
  description = "Master username for the RDS PostgreSQL server"
  type        = string
}

# Supplies the PostgreSQL administrator password to RDS at creation time.
variable "db_password" {
  description = "Master password for the RDS PostgreSQL server"
  type        = string
  sensitive   = true
}
