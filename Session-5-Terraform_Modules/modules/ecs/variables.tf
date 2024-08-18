variable "prefix" {
  type        = string
  description = "Prefix to many of the resources created which helps as an identifier, could be company name, solution name, etc"
}

variable "region" {
  type        = string
  description = "Region to deploy the solution"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  description = "Number of private subnets in the VPC"
  type        = list(string)
}

variable "alb_target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group Id"
  type        = string
}