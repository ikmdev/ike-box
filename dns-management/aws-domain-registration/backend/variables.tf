variable "aws_region" {
  description = "AWS region to use for resources"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Tofu state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Tofu state locking"
  type        = string
}
