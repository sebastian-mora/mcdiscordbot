
# Stores the resource ARNS required by SLS


resource "aws_ssm_parameter" "dynamodb-mc" {
  name = aws_dynamodb_table.mc-table.name
  type = "SecureString"
  value = aws_dynamodb_table.mc-table.arn
}


resource "aws_ssm_parameter" "discord-webhook" {
  name = "discord-webhook"
  type = "SecureString"
  value = var.discord-webhook
}

resource "aws_ssm_parameter" "rconpass" {
  name = "rconpass"
    type = "SecureString"
    value = var.rconpass
}