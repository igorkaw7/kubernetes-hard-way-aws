variable "vpc_parameters" {
  type = object({
    cidr_block           = optional(string, "10.0.0.0/16")
    enable_dns_support   = optional(bool, true)
    enable_dns_hostnames = optional(bool, true)
  })

  default = {}
}

variable "public_subnet_parameters" {
  type = object({
    cidr_block              = optional(string, "10.0.1.0/24")
    map_public_ip_on_launch = optional(bool, true)
    availability_zone       = optional(string)
  })

  default = {}
}

variable "private_subnet_parameters" {
  type = object({
    cidr_block        = optional(string, "10.0.2.0/24")
    availability_zone = optional(string)
  })

  default = {}
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "create_nat" {
  description = "Create a NAT gateway for private subnet outbound internet access"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to apply to created resources"
  type        = map(string)
  default     = {}
}
