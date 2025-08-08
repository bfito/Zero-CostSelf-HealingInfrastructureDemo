provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "jp-terraform-demo-bucket-123456" # must be globally unique
  acl    = "private"
}

