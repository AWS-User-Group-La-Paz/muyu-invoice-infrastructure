# AWS region where the VPC will be created.
variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region to use for all resources"
  type        = string
}

# Availability Zones used to place resources in more than one location.
variable "availability_zone1" {
  default     = "us-east-1a"
  description = "The first Availability Zone for subnet placement"
  type        = string
}

variable "availability_zone2" {
  default     = "us-east-1b"
  description = "The second Availability Zone for subnet placement"
  type        = string
}

# CIDR block for the whole VPC.
variable "vpc_cidr" {
  default     = "10.10.0.0/16"
  description = "The CIDR block to use in the VPC"
  type        = string
}

# CIDR blocks for public subnets.
variable "subnet_public1_cidr" {
  default     = "10.10.10.0/24"
  description = "The CIDR block to use in the public subnet 1"
  type        = string
}

variable "subnet_public2_cidr" {
  default     = "10.10.11.0/24"
  description = "The CIDR block to use in the public subnet 2"
  type        = string
}

# CIDR blocks for private subnets.
variable "subnet_private1_cidr" {
  default     = "10.10.20.0/24"
  description = "The CIDR block to use in the private subnet 1"
  type        = string
}

variable "subnet_private2_cidr" {
  default     = "10.10.21.0/24"
  description = "The CIDR block to use in the private subnet 2"
  type        = string
}
