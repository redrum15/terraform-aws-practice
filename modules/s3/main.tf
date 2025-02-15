locals {
  common_tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "firstbucket" {
  bucket              = var.bucket_name
  object_lock_enabled = false

  tags = local.common_tags
}


resource "aws_s3_bucket_versioning" "versioning_bucket" {
  bucket = aws_s3_bucket.firstbucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.firstbucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}


resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.firstbucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
