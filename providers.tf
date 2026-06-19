# Terraform version pinning keeps local runs predictable.
terraform {
  required_version = "1.15.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.51.0"
    }
  }
}

# AWS credentials and region come from the local AWS CLI environment.
provider "aws" {
  # Default tags apply to future AWS resources that support tagging.
  default_tags {
    tags = {
      Project    = "Muyu"
      ManagedBy  = "Terraform"
      Repository = "muyu-infrastructure"
      Owner      = "<your-name-here>"
    }
  }
}
