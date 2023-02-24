data "terraform_remote_state" "setup" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket  = "${var.resource_prefix}-${var.aws_region}-tf-state"
    region  = var.aws_region
    key     = "imatch-us-gov-west-1-tfsetup.tfstate"
    profile = "imatch-mgmt"
  }
}

data "terraform_remote_state" "network-mgmt" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket  = "${var.resource_prefix}-${var.aws_region}-tf-state"
    region  = var.aws_region
    key     = "imatch-us-gov-west-1-network-mgmt.tfstate"
    profile = "imatch-mgmt"
  }
}

data "terraform_remote_state" "active-directory" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket  = "${var.resource_prefix}-${var.aws_region}-tf-state"
    region  = var.aws_region
    key     = "imatch-us-gov-west-1-active-directory.tfstate"
    profile = "imatch-mgmt"
  }
}

data "terraform_remote_state" "nessusburp" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket  = "${var.resource_prefix}-${var.aws_region}-tf-state"
    region  = var.aws_region
    key     = "imatch-us-gov-west-1-nessusburp.tfstate"
    profile = "imatch-mgmt"
  }
}

data "terraform_remote_state" "jira" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket  = "${var.resource_prefix}-${var.aws_region}-tf-state"
    region  = var.aws_region
    key     = "imatch-us-gov-west-1-jira-state.tfstate"
    profile = "imatch-mgmt"
  }
}
