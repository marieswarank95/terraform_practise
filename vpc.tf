# VPC creation
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = var.project_name
    Environment = var.env_name
  }
}

# Public subnet creation
resource "aws_subnet" "public_subnet" {
  count                   = length(slice(data.aws_availability_zones.us-east-1_az.names, 0, 2))
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.us-east-1_az.names, count.index)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.env_name}-public-subnet-${count.index}"
  }
}

# Private subnet creation
resource "aws_subnet" "private_subnet" {
  count                   = length(slice(data.aws_availability_zones.us-east-1_az.names, 0, 2))
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.us-east-1_az.names, count.index)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 2)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project_name}-${var.env_name}-private-subnet-${count.index}"
  }
}

# Internet gateway creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-${var.env_name}-vpc"
  }
}

# EIP creation for NAT Gateway
resource "aws_eip" "ngw_eip" {
  domain = "vpc"
  count  = length(slice(data.aws_availability_zones.us-east-1_az.names, 0, 2))
  tags = {
    Name = "EIP-${count.index}"
  }
}

# Nat gateway creation
resource "aws_nat_gateway" "ngw" {
  count         = length(slice(data.aws_availability_zones.us-east-1_az.names, 0, 2))
  allocation_id = element(aws_eip.ngw_eip[*].allocation_id, count.index)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)
  tags = {
    Name = "${var.project_name}-${var.env_name}-vpc"
  }
}

# Public subnet route table creation
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-${var.env_name}-public-subnet-rt"
  }
}

# Private subnet route table creation
resource "aws_route_table" "private_subnet_rt_az1" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-${var.env_name}-private-subnet-rt-az1"
  }
}

# Private subnet route table creation
resource "aws_route_table" "private_subnet_rt_az2" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-${var.env_name}-private-subnet-rt-az2"
  }
}

# Public subnet route creation
resource "aws_route" "public_subnet_route" {
  route_table_id         = aws_route_table.public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Private subnet route creation
resource "aws_route" "private_subnet_route_az1" {
  route_table_id         = aws_route_table.private_subnet_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[0].id
}

# Private subnet route creation
resource "aws_route" "private_subnet_route_az2" {
  route_table_id         = aws_route_table.private_subnet_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[1].id
}

# Public subnet route table association
resource "aws_route_table_association" "public_subnet_rt_association" {
  count          = length(slice(data.aws_availability_zones.us-east-1_az.names, 0, 2))
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_subnet_rt.id
}

# Private subnet route table association for az1
resource "aws_route_table_association" "private_subnet_az1_rt_association" {
  subnet_id      = aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.private_subnet_rt_az1.id
}

# Private subnet route table association for az2
resource "aws_route_table_association" "private_subnet_az2_rt_association" {
  subnet_id      = aws_subnet.private_subnet[1].id
  route_table_id = aws_route_table.private_subnet_rt_az2.id
}