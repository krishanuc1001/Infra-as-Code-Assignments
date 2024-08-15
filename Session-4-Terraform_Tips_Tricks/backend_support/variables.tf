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