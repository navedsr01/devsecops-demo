provider "aws" {
  region = var.aws_region
}

# ✅ Check if the bucket already exists
data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_name
}

# ✅ Only create the bucket if it doesn't exist
resource "aws_s3_bucket" "github_bucket" {
  count  = length(data.aws_s3_bucket.existing_bucket.id) > 0 ? 0 : 1
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true  # Avoid accidental deletions
    ignore_changes  = [acl, force_destroy]  # Ignore minor changes to avoid recreation
  }
}

# ✅ Block Public Access
resource "aws_s3_bucket_public_access_block" "public_access" {
  count  = length(data.aws_s3_bucket.existing_bucket.id) > 0 ? 0 : 1
  bucket = var.bucket_name

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Enable Default Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = length(data.aws_s3_bucket.existing_bucket.id) > 0 ? 0 : 1
  bucket = var.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ✅ Upload or Update the `test.txt` file
resource "aws_s3_object" "upload_file" {
  bucket                 = var.bucket_name
  key                    = "test.txt"
  source                 = "test.txt"
  content_type           = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    ignore_changes = [etag]  # Ensure object updates without bucket recreation
  }
}