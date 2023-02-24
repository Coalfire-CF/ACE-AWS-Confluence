variable "upload_directory" {
  default = "../../../../../s3/installs/confluence/"
}
resource "aws_s3_object" "confluence_files" {
  provider = aws.mgmt

  for_each   = fileset(var.upload_directory, "**/*.*")
  bucket     = data.terraform_remote_state.setup.outputs.install_bucket_name
  key        = "confluence/${replace(each.value, var.upload_directory, "")}"
  source     = "${var.upload_directory}${each.value}"
  kms_key_id = data.terraform_remote_state.setup.outputs.s3_key_arn

}
