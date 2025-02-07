provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "github_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_object" "upload_file" {
  bucket = aws_s3_bucket.github_bucket.id
  key    = "test.txt"
  source = "test.txt"  # This file will be uploaded to S3
}