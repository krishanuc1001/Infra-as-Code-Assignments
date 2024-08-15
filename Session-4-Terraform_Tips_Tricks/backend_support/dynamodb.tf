resource "aws_dynamodb_table" "terraform_locks" {
  name         = format("%s-tfstate-locks", var.prefix)
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}