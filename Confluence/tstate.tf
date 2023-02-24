terraform {
  required_version = "~>1.2.0"
  backend "s3" {
    profile        = "imatch-mgmt"
    bucket         = "imatch-us-gov-west-1-tf-state"
    region         = "us-gov-west-1"
    key            = "imatch-us-gov-west-1-confluence-state.tfstate"
    dynamodb_table = "imatch-us-gov-west-1-state-lock"
    encrypt        = true
  }
}
