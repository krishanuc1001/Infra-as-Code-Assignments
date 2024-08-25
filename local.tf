locals {
  vpc_id = module.vpc.vpc_id
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnet_cidrs  = [for i in range(var.public_subnets) : cidrsubnet(var.vpc_cidr, 3, i + 1)]
  private_subnet_cidrs = [for i in range(var.private_subnets) : cidrsubnet(var.vpc_cidr, 3, i + 3)]
  secure_subnet_cidrs  = [for i in range(var.secure_subnets) : cidrsubnet(var.vpc_cidr, 3, i + 5)]
}