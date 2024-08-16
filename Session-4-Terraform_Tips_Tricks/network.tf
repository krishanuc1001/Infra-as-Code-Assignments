resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = format("%s-vpc", var.prefix)
  }
}

resource "aws_subnet" "subnet_public" {
  count                   = local.number_of_public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, count.index + 1)
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.region, element(["a", "b"], count.index))

  tags = {
    Name = format("%s-public-subnet-%d", var.prefix, count.index + 1)
  }
}

resource "aws_subnet" "subnet_private" {
  for_each                = { for i in range(local.number_of_private_subnets) : i => i }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, each.key + 3)
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.region, element(["a", "b"], each.key))

  tags = {
    Name = format("%s-private-subnet-%d", var.prefix, each.key + 1)
  }
}

resource "aws_subnet" "subnet_secure" {
  for_each                = { for i in range(local.number_of_secure_subnets) : i => i }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, each.key + 5)
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.region, element(["a", "b"], each.key))

  tags = {
    Name = format("%s-secure-subnet-%d", var.prefix, each.key + 1)
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
  subnet_id     = aws_subnet.subnet_private[0].id

  tags = {
    Name = format("%s-nat", var.prefix)
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_routetable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = format("%s-public-route-table", var.prefix)
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private_routetable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = format("%s-private-route-table", var.prefix)
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public_subnet" {
  count          = local.number_of_route_tables_association_public_subnet
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.public_routetable.id
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private_subnet" {
  for_each       = aws_subnet.subnet_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_routetable.id
}
