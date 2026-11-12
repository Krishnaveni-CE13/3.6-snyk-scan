variable "aws_region" {
  description = "AWS region for the Lambda function"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the deployed Lambda function"
  type        = string
  default     = "snyk-scan-hello-world"
}