resource "random_string" "random" {
  length  = 6
  special = false
}

resource "aws_s3_bucket" "mc-worlds" {

  bucket = "mc-worlds-${lower(random_string.random.result)}"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name = "Minecraft World Store"
  }
}

resource "aws_s3_bucket_object" "upload-scripts" {
  for_each = fileset("./resources/scripts", "*")
  bucket   = aws_s3_bucket.mc-worlds.id
  key      = "/scripts/${each.value}"
  source   = "./resources/scripts/${each.value}"
  etag     = filemd5("./resources/scripts/${each.value}")
}

resource "aws_s3_bucket_object" "upload-configs" {
  for_each = fileset("./resources/server-configs", "**/*")
  bucket   = aws_s3_bucket.mc-worlds.id
  key      = "/server-configs/${each.value}"
  source   = "./resources/server-configs/${each.value}"
  etag     = filemd5("./resources/server-configs/${each.value}")
}