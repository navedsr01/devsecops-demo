provider "aws" {
  region = var.aws_region
}

# ✅ Create an S3 bucket
resource "aws_s3_bucket" "github_bucket" {
  bucket = var.bucket_name
}

# ✅ Block Public Access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.github_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Enable Default Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.github_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ✅ Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.github_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ✅ Enable S3 Logging (Using a separate log bucket)
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.bucket_name}-logs"
}

resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.github_bucket.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "logs/"
}

# ✅ Upload a Test File to S3
resource "aws_s3_object" "upload_file" {
  bucket                 = aws_s3_bucket.github_bucket.id
  key                    = "test.txt"
  source                 = "test.txt"
  content_type           = "text/plain"
  server_side_encryption = "AES256"
}