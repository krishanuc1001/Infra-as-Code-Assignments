resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = format("%s-vpc", var.prefix)
  }
}

import {
  to = aws_subnet.subnet_public_1
  id = "subnet-027e38db3adebb9cb"
}

resource "aws_subnet" "subnet_public_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.1.96/28"
  map_public_ip_on_launch = "true"
  availability_zone       = format("%sa", var.region)

  tags = {
    Name = "tw-krish-iac-lab-dev-subnet-1"
  }
}
