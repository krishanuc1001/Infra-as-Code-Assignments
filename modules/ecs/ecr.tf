resource "aws_ecr_repository" "api" {
  name                 = "${var.prefix}-crud-app"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = format("%s-ecr-repository", var.prefix)
  }
}