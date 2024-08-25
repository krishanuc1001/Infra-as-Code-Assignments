locals {
  vpc_id = module.vpc.vpc_id
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  number_of_public_subnets  = var.public_subnets
  number_of_private_subnets = var.private_subnets
  number_of_secure_subnets  = var.secure_subnets

  public_subnet_cidrs  = [for i in range(number_of_public_subnets) : cidrsubnet(var.vpc_cidr, 3, i + 1)]
  private_subnet_cidrs = [for i in range(number_of_private_subnets) : cidrsubnet(var.vpc_cidr, 3, i + 3)]
  secure_subnet_cidrs  = [for i in range(number_of_secure_subnets) : cidrsubnet(var.vpc_cidr, 3, i + 5)]
}