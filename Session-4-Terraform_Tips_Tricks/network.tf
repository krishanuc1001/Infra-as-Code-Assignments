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
# resource "aws_subnet" "subnet_public_1" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.subnet1_cidr
#   map_public_ip_on_launch = "true"
#   availability_zone       = format("%sa", var.region)
#
#   tags = {
#     Name = format("%s-public-subnet-1", var.prefix)
#   }
# }
#
#
# resource "aws_subnet" "subnet_public_2" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.subnet2_cidr
#   map_public_ip_on_launch = "true"
#   availability_zone       = format("%sb", var.region)
#
#   tags = {
#     Name = format("%s-public-subnet-2", var.prefix)
#   }
# }

resource "aws_subnet" "subnet_public" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.combined_public_subnet_cidr, 3, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.region, element(["a", "b"], count.index))

  tags = {
    Name = format("%s-public-subnet-%d", var.prefix, count.index + 1)
  }
}

# Private Subnets
# resource "aws_subnet" "subnet_private_1" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.subnet3_cidr
#   map_public_ip_on_launch = "false"
#   availability_zone       = format("%sa", var.region)
#
#   tags = {
#     Name = format("%s-private-subnet-1", var.prefix)
#   }
# }
#
#
# resource "aws_subnet" "subnet_private_2" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.subnet4_cidr
#   map_public_ip_on_launch = "false"
#   availability_zone       = format("%sb", var.region)
#
#   tags = {
#     Name = format("%s-private-subnet-2", var.prefix)
#   }
# }

resource "aws_subnet" "subnet_private" {
  for_each                = { for i in range(2) : i => i }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.combined_private_subnet_cidr, 3, each.key)
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.region, element(["a", "b"], each.key))

  tags = {
    Name = format("%s-private-subnet-%d", var.prefix, each.key + 1)
  }
}

# Secure subnets
# resource "aws_subnet" "subnet_secure_1" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.subnet5_cidr
#   map_public_ip_on_launch = "false"
#   availability_zone       = format("%sa", var.region)
#
#   tags = {
#     Name = format("%s-secure-subnet-1", var.prefix)
#   }
# }
#
# resource "aws_subnet" "subnet_secure_2" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.subnet6_cidr
#   map_public_ip_on_launch = "false"
#   availability_zone       = format("%sb", var.region)
#
#   tags = {
#     Name = format("%s-secure-subnet-2", var.prefix)
#   }
# }

resource "aws_subnet" "subnet_secure" {
  for_each                = { for i in range(2) : i => i }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.combined_secure_subnet_cidr, 4, each.key)
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
  subnet_id     = aws_subnet.subnet_private_1.id

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
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.subnet_public_1.id
  route_table_id = aws_route_table.public_routetable.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.subnet_public_2.id
  route_table_id = aws_route_table.public_routetable.id
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.subnet_private_1.id
  route_table_id = aws_route_table.private_routetable.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.subnet_private_2.id
  route_table_id = aws_route_table.private_routetable.id
}
