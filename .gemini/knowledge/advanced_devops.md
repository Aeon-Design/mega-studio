# Advanced DevOps Grimoire ♾️

> **Domain:** CI/CD, Infrastructure as Code, Deployment Automation
> **Goal:** Invisible, automated production pipelines.

## 🏗️ Infrastructure as Code (IaC)
- **Terraform:** No manual cloud changes. Use remote state storage (GCS/S3).
- **Modules:** Create reusable modules for VPC, DB, and Compute.
- **Validation:** Run `terraform plan` in CI before every apply.

## 🚀 CI/CD Pipelines (GitOps)
- **GitHub Actions:** Shard test suites to run in parallel (< 5 mins).
- **Environments:** Strict separation of Dev, Staging, and Production.
- **Rollbacks:** Automated rollback if health checks fail after deployment.

## 🛡️ Cloud Security
- **Least Privilege:** Use IAM service accounts with scoped permissions.
- **Secrets:** Use Secret Manager/Vault. Never store secrets in CI variables.

## 📊 Observability
- **Log Aggregation:** Standard JSON logs for all services.
- **Tracing:** OpenTelemetry for cross-service request tracing.
- **Alerts:** Error budget alerts (SLIs/SLOs).
