resource "aws_s3_bucket" "s3_cloud_bucket" {
  bucket        = "${var.prefix}-tf-cloud"
  force_destroy = true

  tags = {
    Name = "${var.prefix}-tf-cloud"
  }
}