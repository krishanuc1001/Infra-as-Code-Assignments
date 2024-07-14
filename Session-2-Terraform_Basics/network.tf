resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = format("%s-vpc", var.prefix)
  }
}

# Public Subnets
resource "aws_subnet" "subnet_public_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet1_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = format("%sa", var.region)

  tags = {
    Name = format("%s-public-subnet-1", var.prefix)
  }
}


resource "aws_subnet" "subnet_public_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet2_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = format("%sb", var.region)

  tags = {
    Name = format("%s-public-subnet-2", var.prefix)
  }
}

# Private Subnets
resource "aws_subnet" "subnet_private_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet3_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = format("%sa", var.region)

  tags = {
    Name = format("%s-private-subnet-1", var.prefix)
  }
}


resource "aws_subnet" "subnet_private_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet4_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = format("%sb", var.region)

  tags = {
    Name = format("%s-private-subnet-2", var.prefix)
  }
}

# Secure subnets
resource "aws_subnet" "subnet_secure_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet5_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = format("%sa", var.region)

  tags = {
    Name = format("%s-secure-subnet-1", var.prefix)
  }
}

resource "aws_subnet" "subnet_secure_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet6_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = format("%sb", var.region)

  tags = {
    Name = format("%s-secure-subnet-2", var.prefix)
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-igw", var.prefix)
  }
}

# Elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
}

# NAT Gateway (associate it with the Elastic IP above, with one of the private subnets and use a suitable tag name)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet_private_1.id

  tags = {
    Name = format("%s-nat", var.prefix)
  }
}