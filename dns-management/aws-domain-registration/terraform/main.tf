# DNS setup for testing purposes only.

# Configure Terraform
terraform {
  required_version = ">= 1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
  backend "s3" {
    region         = "us-east-1"
    bucket         = "fdashield-infrastructure-terraformstatefile"
    key            = "ike-inbox-dnshosting.tfstate"
    dynamodb_table = "fdashield-terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_route53domains_domain" "main" {
  domain_name        = var.domain_name
  auto_renew         = false
  registrant_privacy = true
  admin_privacy      = true
  tech_privacy       = true

  admin_contact {
    address_line_1 = var.contact_info.address_line_1
    city           = var.contact_info.city
    contact_type   = var.contact_info.contact_type
    country_code   = var.contact_info.country_code
    email          = var.contact_info.email
    first_name     = var.contact_info.first_name
    last_name      = var.contact_info.last_name
    phone_number   = var.contact_info.phone_number
    state          = var.contact_info.state
    zip_code       = var.contact_info.zip_code
  }

  registrant_contact {
    address_line_1 = var.contact_info.address_line_1
    city           = var.contact_info.city
    contact_type   = var.contact_info.contact_type
    country_code   = var.contact_info.country_code
    email          = var.contact_info.email
    first_name     = var.contact_info.first_name
    last_name      = var.contact_info.last_name
    phone_number   = var.contact_info.phone_number
    state          = var.contact_info.state
    zip_code       = var.contact_info.zip_code
  }

  tech_contact {
    address_line_1 = var.contact_info.address_line_1
    city           = var.contact_info.city
    contact_type   = var.contact_info.contact_type
    country_code   = var.contact_info.country_code
    email          = var.contact_info.email
    first_name     = var.contact_info.first_name
    last_name      = var.contact_info.last_name
    phone_number   = var.contact_info.phone_number
    state          = var.contact_info.state
    zip_code       = var.contact_info.zip_code
  }

}