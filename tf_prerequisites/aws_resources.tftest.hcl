# Terraform Test Examples
#
# For more info please see: https://developer.hashicorp.com/terraform/language/tests
# To learn more about mocking providers see: https://developer.hashicorp.com/terraform/language/tests/mocking
#

run "dynamoDb_tests" {

  command = plan

  assert {
    condition     = aws_dynamodb_table.terraform_locks.name == format("%s-tfstate-locks", var.prefix)
    error_message = "DynamoDB table name did not match expected"
  }

  assert {
    condition     = aws_dynamodb_table.terraform_locks.billing_mode == "PAY_PER_REQUEST"
    error_message = "DynamoDB billing mode did not match expected"
  }

  assert {
    condition     = aws_dynamodb_table.terraform_locks.hash_key == "LockID"
    error_message = "DynamoDB lock Id did not match expected"
  }
}

run "iam_tests" {

  command = plan

  assert {
    condition     = aws_iam_role.github_actions_role.name == format("%s-github-actions-role", var.prefix)
    error_message = "IAM role name did not match expected"
  }

}

run "s3_tests" {

  command = plan

  assert {
    condition     = aws_s3_bucket.s3_bucket.bucket == format("%s-tfstate", var.prefix)
    error_message = "S3 bucket name did not match expected"
  }
}