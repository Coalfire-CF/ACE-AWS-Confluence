data "aws_iam_policy_document" "confluence_policy" {
  provider = aws.mgmt

  statement {
    sid    = "AllowEC2CreateTags"
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ec2:CreateTags"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowRDSReboot"
    effect = "Allow"
    actions = [
      "rds:RebootDBInstance",
      "rds:DescribeDBInstances"
    ]
    resources = [module.confluence-db.db_instance_arn]
  }

  statement {
    sid    = "AllowInstallBucketPermissions"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["arn:${var.partition}:s3:::${data.terraform_remote_state.setup.outputs.install_bucket_name}/confluence"]
  }

  ####### Uncomment if deploying other Atlassian Tools #######

  #   statement {
  #     sid    = "AllowGetSecretsRootCA"
  #     effect = "Allow"
  #     actions = [
  #       "secretsmanager:GetSecretValue",
  #       "secretsmanager:DescribeSecret",
  #       "secretsmanager:ListSecretVersionIds",
  #       "secretsmanager:ListSecrets"
  #     ]
  #     resources = [
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}root_ca_pub.pem*",
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}confluence_cert*",
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}confluence_cert_key*",
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}bitbucket_cert*",
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}bitbucket_cert_key*",
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}jira1_cert*",
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}jira1_cert_key*",
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}bamboo_cert*",
  #       "arn:${var.partition}:secretsmanager:${var.aws_region}:${local.mgmt_account_id}:secret:${var.ca_secrets_rootca_path}bamboo_cert_key*",
  #     ]
  #   }
}

resource "aws_iam_policy" "confluence_policy" {
  provider = aws.mgmt

  name   = "confluence_policy"
  policy = data.aws_iam_policy_document.confluence_policy.json
}


