resource "random_string" "confluence_admin_credential" {
  length           = 15
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!#%"
}

resource "random_string" "confluence_db_password" {
  length           = 15
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!#%"
}

resource "random_string" "svc_confluence_pass" {
  length           = 15
  special          = true
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!#%"
}

resource "aws_secretsmanager_secret" "confluence_admin_credential" {
  provider   = aws.mgmt
  name       = "${var.confluence_secrets_path}admin"
  kms_key_id = data.terraform_remote_state.setup.outputs.secrets_manager_key_id
}

resource "aws_secretsmanager_secret_version" "confluence_admin_credential" {
  provider      = aws.mgmt
  secret_id     = "${var.confluence_secrets_path}admin"
  secret_string = random_string.confluence_admin_credential.result
  depends_on    = [aws_secretsmanager_secret.confluence_admin_credential]
}

resource "aws_secretsmanager_secret" "confluence_db_name" {
  provider   = aws.mgmt
  name       = "${var.confluence_secrets_path}confluence_db_name"
  kms_key_id = data.terraform_remote_state.setup.outputs.secrets_manager_key_id
}

resource "aws_secretsmanager_secret_version" "confluence_db_name" {
  provider      = aws.mgmt
  secret_id     = aws_secretsmanager_secret.confluence_db_name.id
  secret_string = "confluence"
  depends_on    = [aws_secretsmanager_secret.confluence_db_name]
}

resource "aws_secretsmanager_secret" "confluence_db_username" {
  provider   = aws.mgmt
  name       = "${var.confluence_secrets_path}confluence_db_username"
  kms_key_id = data.terraform_remote_state.setup.outputs.secrets_manager_key_id
}

resource "aws_secretsmanager_secret_version" "confluence_db_username" {
  provider      = aws.mgmt
  secret_id     = aws_secretsmanager_secret.confluence_db_username.id
  secret_string = "confluence_admin"
  depends_on    = [aws_secretsmanager_secret.confluence_db_username]
}

resource "aws_secretsmanager_secret" "confluence_db_password" {
  provider   = aws.mgmt
  name       = "${var.confluence_secrets_path}confluence_db_password"
  kms_key_id = data.terraform_remote_state.setup.outputs.secrets_manager_key_id
}

resource "aws_secretsmanager_secret_version" "confluence_db_password" {
  provider      = aws.mgmt
  secret_id     = aws_secretsmanager_secret.confluence_db_password.id
  secret_string = random_string.confluence_db_password.result
  depends_on    = [aws_secretsmanager_secret.confluence_db_password]
}

resource "aws_secretsmanager_secret" "svc_confluence" {
  provider   = aws.mgmt
  name       = "${var.confluence_secrets_path}svc_confluence"
  kms_key_id = data.terraform_remote_state.setup.outputs.secrets_manager_key_id
}

resource "aws_secretsmanager_secret_version" "svc_confluence" {
  provider      = aws.mgmt
  secret_id     = "${var.confluence_secrets_path}svc_confluence"
  secret_string = random_string.svc_confluence_pass.result
  depends_on    = [aws_secretsmanager_secret.svc_confluence]
}
