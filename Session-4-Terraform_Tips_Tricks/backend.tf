terraform {
  backend "s3" {
    bucket  = "tw-krish-iac-lab-tfstate"
    key     = "terraform.tfstate"
    region  = "ap-south-1"
    profile = "tw-beach"

    dynamodb_table = "tw-krish-iac-lab-tfstate-locks"
    encrypt        = true
  }
}