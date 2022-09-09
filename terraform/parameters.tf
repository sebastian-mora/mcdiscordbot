
# Stores the resource ARNS required by SLS


resource "aws_ssm_parameter" "dynamodb-mc" {
  name  = "/mc/${aws_dynamodb_table.mc-table.name}"
  type  = "SecureString"
  value = aws_dynamodb_table.mc-table.arn
}


resource "aws_ssm_parameter" "discord-webhook" {
  name  = "/mc/discord-webhook"
  type  = "SecureString"
  value = var.discord-webhook
}

resource "aws_ssm_parameter" "rconpass" {
  name  = "/mc/rconpass"
  type  = "SecureString"
  value = var.rconpass
}

resource "aws_ssm_parameter" "sns_topic" {
  name  = "/mc/alert-sns"
  type  = "SecureString"
  value = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:mcalerts"
}

resource "aws_ssm_parameter" "backup-bucket" {
  name  = "/mc/backup-bucket"
  type  = "SecureString"
  value = aws_s3_bucket.mc-worlds.id
}

resource "aws_ssm_parameter" "backup-version-limit" {
  name  = "/mc/version-limit"
  type  = "SecureString"
  value = "3"
}

resource "aws_ssm_parameter" "ssh-deploy-key" {
  name = "mc/ssh-deploy-key"
  type = "SecureString"
  value = var.ssh_deploy_key
}