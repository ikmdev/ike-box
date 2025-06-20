
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

