# Repository Guidelines

## Project Structure & Module Organization

This repository provisions the Muyu invoice service on AWS with Terraform. Root `*.tf` files define shared infrastructure: networking (`vpc.tf`), ECS services (`services.tf`), IAM, RDS, S3, SQS, SES, ECR, and observability. Reusable ECS building blocks live in `modules/ecs-cluster/` and `modules/ecs-service/`; each module keeps `main.tf`, `variables.tf`, and `outputs.tf` together. `terraform.tfvars` contains deployment-specific values; do not commit secrets or generated plan/state files.

## Build, Test, and Development Commands

Install pinned tools with `mise install`, then confirm AWS credentials with `aws sts get-caller-identity`.

- `mise run check` — runs `terraform fmt -check -recursive` and `terraform validate`.
- `mise run plan` — creates `tfplan.binary` and its JSON form, `tfplan.json`.
- `mise run scan` — scans the generated plan using Checkov and `.checkov.yml`.
- `mise run cost` — estimates hourly and monthly costs with Infracost; set `INFRACOST_API_KEY` first.
- `terraform apply tfplan.binary` — applies the reviewed plan. Follow the staged deployment steps in `README.md` for workshop deployments.

## Coding Style & Naming Conventions

Use `terraform fmt` formatting (two-space indentation). Keep resource labels lowercase and descriptive, such as `aws_sqs_queue.invoice_pdf_jobs`; use `this` only inside reusable modules. Add variables and outputs to the relevant module file, with explicit types and short descriptions. Prefer names derived from `var.name_prefix` so AWS resources remain grouped per deployment.

## Testing Guidelines

Run `mise run check` before every change. Run `mise run plan` for infrastructure changes, then `mise run scan` when a plan is available. The GitHub Actions workflow enforces formatting and `terraform validate` with backend initialization disabled; ensure those checks pass before requesting review.

## Commit & Pull Request Guidelines

Follow the existing Conventional Commit style: `feat: add ...`, `fix: ...`, or `chore(scope): ...`. Keep commits focused. PRs should explain the infrastructure impact, link the relevant issue when applicable, include the reviewed plan or a concise summary of it, and call out cost, security, or manual AWS steps (for example, SES email verification).

## Security & Configuration

Treat `terraform.tfvars`, plan files, and Terraform state as sensitive. Use local AWS credentials; never place credentials, passwords, or API keys in `.tf` files, commits, or PR descriptions. Use a verified SES sender address configured through `email_from`.
