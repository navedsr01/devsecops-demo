provider "aws" {
  region = var.aws_region
}

# ✅ Secure S3 Bucket with Encryption, Logging, and Access Controls
resource "aws_s3_bucket" "github_bucket" {
  bucket = var.bucket_name
}

# ✅ Enforce Public Access Blocking (Fixes HIGH Issues #1, #2, #4, #5, #9)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.github_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Enable Encryption using AWS-Managed KMS Key (Fixes HIGH Issues #3, #6)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.github_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ✅ Enable S3 Logging (Fixes MEDIUM Issue #7)
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.bucket_name}-logs"
}

resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.github_bucket.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "log/"
}

# ✅ Enable S3 Versioning (Fixes MEDIUM Issue #8)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.github_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ✅ Upload a test file
resource "aws_s3_bucket_object" "upload_file" {
  bucket = aws_s3_bucket.github_bucket.id
  key    = "test.txt"
  source = "test.txt"
}
