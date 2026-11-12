# 3.6 Package Vulnerability Scan

This repository deploys a Python AWS Lambda that returns `Hello, World!` and applies package, code, and infrastructure-as-code security checks to pull requests.

## Required pull request checks

- `terraform-checks`: Terraform formatting, initialization, validation, and TFLint.
- `snyk-checks`: Snyk Open Source, Code, and IaC scans.

Both checks are required by the `main` branch protection rule.

## Deployment

After a successful pull request is merged, `cd.yml` authenticates to AWS through GitHub OIDC, applies Terraform, invokes the Lambda, and prints its response. No long-lived AWS access key is stored in GitHub.
