providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
}
resource "aws_lambda_function" "helloworld" {
  function_name = "helloworld"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "helloworld.display"
  runtime       = "python3.9"

  filename      = "lambda.zip"

  source_code_hash = filebase64sha256("lambda.zip")
}
resource "aws_iam_role" "krish-synk-scan" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}