variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "github-actions-secure-bucket"
}

variable "random_suffix" {
  default = "123456"  # Replace with a generated random value
}