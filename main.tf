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
    ignore_changes  = [force_destroy]  # Remove deprecated acl
  }
}

# ✅ Upload all files from `source/` to S3 using for_each
resource "aws_s3_object" "upload_files" {
  for_each = fileset("${path.module}/source", "**")

  bucket                 = var.bucket_name
  key                    = each.value
  source                 = "${path.module}/source/${each.value}"
  content_type           = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    ignore_changes = [etag]  # Ensure object updates without bucket recreation
  }
}