resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_parameters.cidr_block
  enable_dns_support   = var.vpc_parameters.enable_dns_support
  enable_dns_hostnames = var.vpc_parameters.enable_dns_hostnames

  tags = merge({ Name = "vpc" }, var.tags)
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_parameters.cidr_block
  map_public_ip_on_launch = var.public_subnet_parameters.map_public_ip_on_launch
  availability_zone       = coalesce(var.public_subnet_parameters.availability_zone, data.aws_availability_zones.available.names[0])

  tags = merge({ Name = "public-subnet" }, var.tags)
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_parameters.cidr_block
  availability_zone       = coalesce(var.private_subnet_parameters.availability_zone, data.aws_availability_zones.available.names[0])
  map_public_ip_on_launch = var.create_nat == false ? true : false

  tags = merge({ Name = "private-subnet" }, var.tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ Name = "igw" }, var.tags)
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge({ Name = "public-rt" }, var.tags)
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  count  = var.create_nat ? 1 : 0
  domain = "vpc"

  tags = var.create_nat ? merge({ Name = "nat-eip" }, var.tags) : {}
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.create_nat ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnet.id

  tags = var.create_nat ? merge({ Name = "nat-gw" }, var.tags) : {}
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.create_nat ? aws_nat_gateway.nat_gw[0].id : null
    gateway_id     = var.create_nat ? null : aws_internet_gateway.igw.id
  }

  tags = merge({ Name = "private-rt" }, var.tags)
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
