# muyu-infrastructure

This repository contains infrastructure code for the Muyu application.

AWS resources for Muyu are managed with Terraform. This repository creates the
network foundation shown below.

## Network Architecture

The network layout is:

- Region: `us-east-1`
- VPC: `10.10.0.0/16`
- Public subnet 1: `10.10.10.0/24` in `us-east-1a`
- Public subnet 2: `10.10.11.0/24` in `us-east-1b`
- Private subnet 1: `10.10.20.0/24` in `us-east-1a`
- Private subnet 2: `10.10.21.0/24` in `us-east-1b`
- Internet Gateway for public subnet internet access
- NAT Gateway in public subnet 1 for private subnet outbound internet access
- One route table for public subnets
- One route table for private subnets
- Resources that support tags use a `Name` tag with the `muyu` prefix

> AWS creates a default route table with every VPC. This example does not use it.
> Each subnet is explicitly associated with either the public route table or the
> private route table so the routing decision is visible in Terraform.

```mermaid
flowchart TB
    internet((Internet))

    subgraph vpc["VPC 10.10.0.0/16"]
        igw["Internet Gateway"]

        subgraph public["Public subnets"]
            public1["Public subnet 1<br/>10.10.10.0/24<br/>us-east-1a"]
            public2["Public subnet 2<br/>10.10.11.0/24<br/>us-east-1b"]
            nat["NAT Gateway<br/>Elastic IP"]
        end

        subgraph private["Private subnets"]
            private1["Private subnet 1<br/>10.10.20.0/24<br/>us-east-1a"]
            private2["Private subnet 2<br/>10.10.21.0/24<br/>us-east-1b"]
        end

        public_rt["Public route table<br/>0.0.0.0/0 -> Internet Gateway"]
        private_rt["Private route table<br/>0.0.0.0/0 -> NAT Gateway"]
    end

    internet --- igw
    igw --- public_rt
    public_rt --- public1
    public_rt --- public2
    public1 --- nat
    nat --- private_rt
    private_rt --- private1
    private_rt --- private2
```

## Terraform Workflow

```sh
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Terraform Plan File

Some checks use the Terraform plan as input:

```sh
terraform plan -out tfplan.binary
terraform show -json tfplan.binary > tfplan.json
```

Do not commit `tfplan.binary` or `tfplan.json`; plan files can contain sensitive values.

## Security Scan

Scan the planned infrastructure with Checkov:

```sh
checkov -f tfplan.json
```

## Cost Estimate

Set the Infracost API key:

```sh
export INFRACOST_API_KEY="<your-api-key>"
```

Estimate the monthly cost of the planned infrastructure:

```sh
infracost breakdown --path tfplan.json
```
