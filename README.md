# muyu-infrastructure

This repository contains infrastructure code for the Muyu application.

AWS resources for Muyu are managed with Terraform. This repository is currently
an intentionally small starting point with provider setup and placeholder files.

## Intended Network Architecture

The planned network layout is:

- One VPC
- Two public subnets
- Two private subnets
- Internet Gateway
- Route Tables

## Terraform Workflow

```sh
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```
