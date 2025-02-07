provider "aws" {
  region = var.aws_region
}

# ✅ Step 1: Create a KMS Key for S3 Encryption (Fixes HIGH #1, #7)
resource "aws_kms_key" "s3_kms_key" {
  description = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "s3_kms_key_alias" {
  name          = "alias/s3-encryption-key"
  target_key_id = aws_kms_key.s3_kms_key.id
}

# ✅ Step 2: Create a Secure S3 Bucket
resource "aws_s3_bucket" "github_bucket" {
  bucket = var.bucket_name
}

# ✅ Step 3: Block Public Access (Fixes HIGH #2, #3, #5, #6 & LOW #10)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.github_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Step 4: Enable Default Encryption using KMS Key (Fixes HIGH #1, #4, #7)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.github_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms_key.id
    }
  }
}

# ✅ Step 5: Enable S3 Logging (Fixes MEDIUM #8)
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.bucket_name}-logs"
}

resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.github_bucket.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "logs/"
}

# ✅ Step 6: Enable S3 Versioning (Fixes MEDIUM #9)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.github_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ✅ Step 7: Upload a Test File to the Bucket
resource "aws_s3_object" "upload_file" {
  bucket                 = aws_s3_bucket.github_bucket.id
  key                    = "test.txt"
  source                 = "test.txt"
  server_side_encryption = "aws:kms"
  kms_key_id             = aws_kms_key.s3_kms_key.arn  # FIX: Use 'arn' instead of 'id'
  content_type           = "text/plain"
}