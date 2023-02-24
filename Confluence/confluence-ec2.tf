data "aws_ami" "rhel_gold_ami" {
  most_recent = true
  owners      = ["self"]
  provider    = aws.mgmt

  filter {
    name   = "name"
    values = ["rhel8-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  db_instance_endpoint = element(split(":", module.confluence-db.db_instance_endpoint), 0)
}

module "confluence" {
  providers = {
    aws = aws.mgmt
  }

  source            = "../../../../modules/aws-ec2"
  name              = "confluence1"
  instance_count    = 1
  ami               = data.aws_ami.rhel_gold_ami.id
  ec2_instance_type = "c5.xlarge"
  ec2_key_pair      = var.key_name
  root_volume_size  = "50"
  subnet_ids = [
    data.terraform_remote_state.network-mgmt.outputs.private_subnets[4],
    data.terraform_remote_state.network-mgmt.outputs.private_subnets[5]
  ]
  vpc_id          = data.terraform_remote_state.network-mgmt.outputs.vpc_id
  ebs_kms_key_arn = data.terraform_remote_state.setup.outputs.ebs_key_arn

  iam_policies = [
    aws_iam_policy.confluence_policy.id,
    data.terraform_remote_state.setup.outputs.base_iam_policy_arn
  ]
  keys_to_grant = [
    data.terraform_remote_state.setup.outputs.s3_key_arn,
    data.terraform_remote_state.setup.outputs.secrets_manager_key_arn
  ]

  tags = {
    OSFamily      = "RHEL8",
    OSType        = "Linux",
    App           = "Management",
    backup_policy = var.backup_policy
  }

  additional_security_groups = [
    aws_security_group.confluence_instance_sg.id,
    data.terraform_remote_state.network-mgmt.outputs.base_mgmt_linux_sg_id,
    data.terraform_remote_state.jira.outputs.jira_app_links_sg
  ]
  cidr_security_group_rules = []

  user_data = [
    {
      path = {
        folder_name = "linux",
        file_name   = "ud-os-join-ad.sh"
      },
      vars = {
        aws_region            = var.aws_region,
        domain_name           = var.domain_name,
        dom_disname           = var.dom_disname,
        ou_env                = var.lin_prod_ou_env,
        linux_admins_ad_group = var.linux_admins_ad_group,
        domain_join_user_name = var.domain_join_user_name,
        sm_djuser_path        = "${var.ad_secrets_path}${var.domain_join_user_name}",
        is_asg                = "false"
      }
    },
    {
      path = {
        folder_name = "linux",
        file_name   = "ud-rds-pgaudit.sh"
      },
      vars = {
        db_instance_endpoint = local.db_instance_endpoint,
        identifier           = "confluence1",
        db_port              = "5432"
        aws_region           = var.aws_region,
        db_password_path     = "${var.confluence_secrets_path}confluence_db_password",
        db_username          = module.confluence-db.db_instance_username,
        db_name              = module.confluence-db.db_instance_name
      }
    },
    {
      path = {
        folder_name = "linux",
        file_name   = "ud-confluence-install.sh"
      },
      vars = {
        aws_region               = var.aws_region,
        domain_name              = var.domain_name,
        confluence_dl_url        = "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-7.19.3-x64.bin"
        confluence_version       = "7.19.3"
        install_s3_bucket        = data.terraform_remote_state.setup.outputs.install_bucket_name,
        install_s3_bucket_folder = "confluence"
      }
    },

  ]
  sg_security_group_rules = []
  cidr_group_rules        = []
  global_tags             = var.global_tags
  regional_tags           = var.regional_tags
}
