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
  source_file = "${path.module}/lambda/index.mjs"
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

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_world" {
  filename         = data.archive_file.lambda.output_path
  function_name    = var.function_name
  handler          = "index.handler"
  role             = aws_iam_role.lambda.arn
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]
}

output "lambda_function_arn" {
  value = aws_lambda_function.hello_world.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.hello_world.function_name
}