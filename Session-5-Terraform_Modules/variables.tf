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

variable "public_subnets" {
  description = "Number of public subnets in the VPC"
  type        = number
}

variable "private_subnets" {
  description = "Number of private subnets in the VPC"
  type        = number
}

variable "secure_subnets" {
  description = "Number of secure subnets in the VPC"
  type        = number
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_name" {
  type        = string
  description = "Database name"
}