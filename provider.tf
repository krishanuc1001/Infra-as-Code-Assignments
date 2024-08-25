terraform {
  required_version = ">= 1.9.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

provider "aws" {
  region  = var.region

  default_tags {
    tags = {
      "ManagedBy"   = "Terraform"
      "Project"     = var.prefix
      "Environment" = "Dev"
    }
  }
}