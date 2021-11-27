
# Stores the resource ARNS required by SLS

resource "aws_ssm_parameter" "sns-arn" {
  name        = aws_sns_topic.mc-updates.name
  description = "Stored the ARN of the SNS topic"
  type        = "SecureString"
  value       = "${aws_sns_topic.mc-updates.arn}"
}

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