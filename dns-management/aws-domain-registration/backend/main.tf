terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "tfstate" {
  bucket = var.s3_bucket_name
  acl    = "private"

  default_server_side_encryption {
    sse_algorithm = "AES256"
  }
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}
