resource "aws_sns_topic" "mc-updates" {
  name = "mc-updates"
}

resource "aws_sns_topic_subscription" "topic_lambda" {
  topic_arn = aws_sns_topic.mc-updates.arn
  protocol  = "lambda"
  endpoint  = var.alert-lambda-arn
}