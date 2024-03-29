resource "random_string" "random" {
  length  = 6
  special = false
}

resource "aws_s3_bucket" "mc-worlds" {
  bucket = "mc-worlds-${lower(random_string.random.result)}"
  tags = {
    Name = "Minecraft World Store"
  }
}


resource "aws_s3_bucket_acl" "wolrds_acl" {
  bucket = aws_s3_bucket.mc-worlds.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_configuration" {
  bucket = aws_s3_bucket.mc-worlds.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "mc-server-files" {
  bucket = "mc-server-files-${lower(random_string.random.result)}"
  tags = {
    Name = "Store minecraft jar and mod files"
  }
}


resource "aws_s3_bucket_acl" "files_acl" {
  bucket = aws_s3_bucket.mc-server-files.id
  acl    = "private"
}
