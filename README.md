# 3.6 Package Vulnerability Scan Assignment

This repository deploys a Node.js AWS Lambda that returns `Hello, World!` and applies package, code, and infrastructure-as-code security checks in pull requests.

## Pull request checks

- `terraform-checks`: Terraform format, initialization, validation, and TFLint.
- `snyk-checks`: Unit tests plus Snyk Open Source, Code, and IaC scans.

Both checks are required before merging to `main`.

## Deployment

Merges to `main` run Terraform through GitHub OIDC, deploy the Lambda, invoke it, and display the response. No long-lived AWS access key is stored in GitHub.
