resource "aws_dynamodb_table" "mc-table" {
  name           = "mcdataa"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "username"

  attribute {
    name = "username"
    type = "S"
  }
}