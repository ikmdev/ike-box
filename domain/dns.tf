# DNS setup for testing purposes only.


# Configure Terraform
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.75.1"
    }
  }
  backend "s3" {
    region         = "us-east-1"
    # dynamodb_table = "Fdashield-Infrastructure-TerraformLockStatus-DynamoDB"
    bucket         = "fdashield-infrastructure-terraformstatefile"

    # Do not change the name below
    key = "ike-inbox-dnshosting.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "domain_name" {
  default = "test-ike.org"
}

resource "aws_route53domains_registered_domain" "main" {
  domain_name = var.domain_name

  admin_contact {
    address_line_1   = "123 Main St"
    city             = "Anytown"
    contact_type     = "PERSON"
    country_code     = "US"
    email            = "sidahal@deloitte.com"
    first_name       = "Sikeey"
    last_name        = "Dahal"
    phone_number     = "+17177436740"
    state            = "PA"
    zip_code         = "10001"
  
  
  }

  registrant_contact {
    address_line_1   = "123 Main St"
    city             = "Anytown"
    contact_type     = "PERSON"
    country_code     = "US"
    email            = "sidahal@deloitte.com"
    first_name       = "Sikeey"
    last_name        = "Dahal"
    phone_number     = "+17177436740"
    state            = "PA"
    zip_code         = "10001"
  }

  tech_contact {
    address_line_1   = "123 Main St"
    city             = "Anytown"
    contact_type     = "PERSON"
    country_code     = "US"
    email            = "sidahal@deloitte.com"
    first_name       = "Sikeey"
    last_name        = "Dahal"
    phone_number     = "+7177436740"
    state            = "PA"
    zip_code         = "10001"
  }

  auto_renew        = false
  registrant_privacy = true
  admin_privacy      = true
  tech_privacy       = true
}
# Reference the VPC
data "aws_vpc" "networkvpc" {
  filter {
    name   = "tag:Name"
    values = ["FdaShield-Network-VPC"]
  }
}
 # create private hosted zone

resource "aws_route53_zone" "private" {
  name = var.domain_name
  vpc {
    vpc_id = data.aws_vpc.networkvpc.id
   
  }
   
}
locals {
  subdomains = [
    "www.ike.org",
    "nexus.ike.org",
    "komet.ike.org",
    "gitea.ike.org",
    "example.ike.org"
  ]
  target_ip = "172.20.3.26"
}

resource "aws_route53_record" "subdomains" {
  for_each = toset(local.subdomains)
  zone_id  = aws_route53_zone.private.zone_id
  name     = "${each.key}.${var.domain_name}"
  type     = "A"
  ttl      = 300
  records  = [local.target_ip]
}
