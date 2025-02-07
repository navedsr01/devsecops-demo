provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "github_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_object" "upload_file" {
  bucket = aws_s3_bucket.github_bucket.id
  key    = "test-file.txt"
  source = "test-file.txt"  # Local file to upload
  etag   = filemd5("test-file.txt")
}

terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}
