locals {
  number_of_public_subnets                         = var.public_subnets
  number_of_private_subnets                        = var.private_subnets
  number_of_secure_subnets                         = var.secure_subnets
  number_of_route_tables_association_public_subnet = var.public_subnets
}