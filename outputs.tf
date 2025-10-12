output "jumpbox_public_ip" {
  value = aws_instance.jumpbox.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the jumpbox with agent forwarding"
  value       = <<-EOT
    # Load the key to SSH agent:
    ssh-add ${var.private_key_path}

    # Connect to jumpbox
    ssh -A -o StrictHostKeyChecking=no admin@${aws_instance.jumpbox.public_ip}
  EOT
}

output "control_plane_private_ip" {
  value = aws_instance.control_plane.private_ip
}

output "worker_private_ips" {
  description = "Private IP addresses of the Kubernetes workers"
  value       = aws_instance.worker[*].private_ip
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  value = module.vpc.nat_gateway_public_ip
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}
