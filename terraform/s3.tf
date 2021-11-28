resource "random_string" "random" {
  length           = 6
  special          = false
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
  for_each = fileset("ec2_scripts/", "*")
  bucket   = aws_s3_bucket.mc-worlds.id
  key      = each.value
  source   = "scripts/${each.value}"
  etag     = filemd5("scripts/${each.value}")
}