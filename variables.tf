# ------------------------------------------------------------------------------
# VPC Configuration
# ------------------------------------------------------------------------------

variable "vpc_parameters" {
  type = object({
    cidr_block           = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
  })
}

variable "public_subnet_parameters" {
  type = object({
    cidr_block              = string
    map_public_ip_on_launch = bool
  })
}

variable "private_subnet_parameters" {
  type = object({
    cidr_block = string
  })
}

variable "create_nat" {
  description = "Create a NAT gateway for private subnet outbound internet access. If set to 'false', private subnet becomes public."
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Instance Configuration
# ------------------------------------------------------------------------------

variable "jumpbox_instance_type" {
  type    = string
  default = "t4g.nano"
}

variable "jumpbox_root_volume_size" {
  description = "The size of the root volume for the jumpbox in GiB."
  type        = number
  default     = 10
}

variable "control_plane_instance_type" {
  description = "The instance type for the control plane node."
  type        = string
  default     = "t4g.small"
}

variable "control_plane_root_volume_size" {
  description = "The size of the root volume for the control plane in GiB."
  type        = number
  default     = 20
}

variable "worker_count" {
  description = "The number of worker nodes to create."
  type        = number
  default     = 2
}

variable "worker_instance_type" {
  description = "The instance type for the worker nodes."
  type        = string
  default     = "t4g.small"
}

variable "worker_root_volume_size" {
  description = "The size of the root volume for the worker nodes in GiB."
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "The type of the root volume for all instances."
  type        = string
  default     = "gp3"
}

# ------------------------------------------------------------------------------
# Misc.
# ------------------------------------------------------------------------------

variable "region" {
  type = string
}

variable "admin_ip" {
  description = "Admin public IP address for SSH access"
  type        = string
}

variable "private_key_path" {
  description = "The local path to the private SSH key to use for generating SSH command to connect to instances"
  type        = string
}

variable "public_key_path" {
  description = "The local path to the public SSH key to use for instances"
  type        = string
}

variable "project_name" {
  description = "The name of the project, used for naming resources."
  type        = string
  default     = "k8s-hard-way"
}

variable "tags" {
  description = "Map of tags applied at the root module level"
  type        = map(string)
  default     = {}
}
