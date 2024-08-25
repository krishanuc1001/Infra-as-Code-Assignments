locals {
  terraform_cloud_oidc_already_exists = false
  // if an entry for 'app.terraform.io' is present in Identity Providers in AWS IAM, change this flag to true
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_openid_connect_provider" "default" {
  count = local.terraform_cloud_oidc_already_exists ? 0 : 1
  url   = "https://app.terraform.io"
  client_id_list = [
    "aws.workload.identity",
  ]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

resource "aws_iam_policy" "iam" {
  name = format("%s-terraform-cloud-deployment-policy", var.prefix)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
        ],
        "Resource" : "*"
      }
    ]
    # Extend permissions as required for the role
  })
}

resource "aws_iam_policy_attachment" "role_policy_attachment" {
  name       = "Policy Attachement"
  policy_arn = aws_iam_policy.iam.arn
  roles = [aws_iam_role.terraform_cloud_role.name]
}

resource "aws_iam_role" "terraform_cloud_role" {
  name = format("%s-terraform-cloud-role", var.prefix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = format("arn:aws:iam::%s:oidc-provider/app.terraform.io", data.aws_caller_identity.current.id)
        }
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals" : {
            format("%s:aud", var.tfc_hostname) : var.tfc_aws_audience
          },
          "StringLike" : {
            format("%s:sub", var.tfc_hostname) : format("organization:%s:project:%s:workspace:%s:run_phase:*", var.tfc_organization_name, var.tfc_project_name, var.tfc_workspace_name)
          }
        }
      }
    ]
  })
}