
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

variable "dns_challenge_value"{
  description = "DNS challenge value for domain verification"
  type        = string
  default     = "sjgBKfaMnZSecaKkYkI8Ayx-CvGH8b1IMmTKiTXc_Q"
}