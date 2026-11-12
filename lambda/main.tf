terraform {
  required_version = ">= 1.10.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    encrypt      = true
    use_lockfile = true
  }
}

variable "aws_region" {
  description = "AWS region for the Lambda function"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Purpose   = "package-vulnerability-scan-assignment"
    }
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/helloworld.py"
  output_path = "${path.module}/lambda.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "package-scan-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray_write" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_lambda_function" "helloworld" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "package-scan-hello-world"
  handler          = "helloworld.handler"
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "python3.13"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_xray_write,
  ]
}

output "lambda_function_arn" {
  value = aws_lambda_function.helloworld.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.helloworld.function_name
}