
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "domain_name" {
  description = "The domain name to register"
  type        = string
}

variable "target_ip" {
  description = "The target IP address for subdomains"
  type        = string
}

variable "subdomains" {
  description = "List of subdomains to create"
  type        = list(string)
}

variable "contact_info" {
  description = "Contact information for domain registration"
  type = object({
    address_line_1 = string
    city           = string
    contact_type   = string
    country_code   = string
    email          = string
    first_name     = string
    last_name      = string
    phone_number   = string
    state          = string
    zip_code       = string
  })
}
variable "dns_challenge_value"{
  description = "DNS challenge value for domain verification"
  type        = string
  default     = ""
}