
# Stores the resource ARNS required by SLS


resource "aws_ssm_parameter" "dynamodb-mc" {
  name  = aws_dynamodb_table.mc-table.name
  type  = "SecureString"
  value = aws_dynamodb_table.mc-table.arn
}


resource "aws_ssm_parameter" "discord-webhook" {
  name  = "discord-webhook"
  type  = "SecureString"
  value = var.discord-webhook
}

resource "aws_ssm_parameter" "rconpass" {
  name  = "rconpass"
  type  = "SecureString"
  value = var.rconpass
}

resource "aws_ssm_parameter" "sns_topic" {
  name = "alert-sns"
  type = "SecureString"
  value = "arn:aws:sns:${data.aws_caller_identity.current.account_id}:${data.aws_region.current.name}:mcalerts"
}

resource "aws_ssm_parameter" "backup-bucket" {
  name = "backup-bucket"
  type = "SecureString"
  value = aws_s3_bucket.mc-worlds.id
}

resource "aws_ssm_parameter" "backup-version-limit" {
  name = "version-limit"
  type = "SecureString"
  value = "3"
}