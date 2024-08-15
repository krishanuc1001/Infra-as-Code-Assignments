variable "prefix" {
  type        = string
  description = "Prefix to many of the resources created which helps as an identifier, could be company name, solution name, etc"
  default     = "tw-krish-iac-lab"
}

variable "region" {
  type        = string
  description = "Region to deploy the solution"
  default     = "ap-south-1"
}

variable "profile" {
  type        = string
  description = "AWS profile to use for the deployment"
  default     = "tw-beach"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

# variable "subnet1_cidr" {
#   type        = string
#   description = "Subnet 1 CIDR block"
# }
#
# variable "subnet2_cidr" {
#   type        = string
#   description = "Subnet 2 CIDR block"
# }

variable "number_of_public_subnets" {
  description = "Number of public subnets in the VPC"
  type = number
}

# variable "subnet3_cidr" {
#   type        = string
#   description = "Subnet 3 CIDR block"
# }
#
# variable "subnet4_cidr" {
#   type        = string
#   description = "Subnet 4 CIDR block"
# }

variable "number_of_private_subnets" {
  description = "Number of private subnets in the VPC"
  type = number
}

# variable "subnet5_cidr" {
#   type        = string
#   description = "Subnet 5 CIDR block"
# }
#
# variable "subnet6_cidr" {
#   type        = string
#   description = "Subnet 6 CIDR block"
# }

variable "number_of_secure_subnets" {
  description = "Number of secure subnets in the VPC"
  type = number
}