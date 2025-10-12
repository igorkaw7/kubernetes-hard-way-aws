output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "public_subnet_cidr" {
  value = aws_subnet.public_subnet.cidr_block
}

output "private_subnet_cidr" {
  value = aws_subnet.private_subnet.cidr_block
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = var.create_nat ? aws_nat_gateway.nat_gw[0].id : null
}

output "nat_gateway_public_ip" {
  value = var.create_nat ? aws_eip.nat_eip[0].public_ip : null
}

output "module_tags" {
  description = "Tags applied by the module (merge base)"
  value       = var.tags
}

output "availability_zone" {
  description = "Availability zone used by the subnets"
  value       = aws_subnet.public_subnet.availability_zone
}
