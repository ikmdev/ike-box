# DNS setup for testing purposes only.
provider "aws" {
  region = "us-east-1"
}

variable "domain_name" {
  default = "sikeeytest.com"
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

resource "aws_route53_zone" "private" {
  name = var.domain_name
  vpc {
    vpc_id = aws_vpc.domain_name.id
  }
}
locals {
  subdomains = [
    "test1",
    "test2",
    "test3",
    "test4",
    "test5"
  ]
  target_ip = "1.2.3.4"
}

resource "aws_route53_record" "subdomains" {
  for_each = toset(local.subdomains)
  zone_id  = aws_route53_zone.main.zone_id
  name     = "${each.key}.${var.domain_name}"
  type     = "A"
  ttl      = 300
  records  = [local.target_ip]
}
