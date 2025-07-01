provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_s3_bucket" "Create-bucket" {
    bucket = "bucker-versioning-akash-2025"
  
}


resource "aws_s3_bucket_versioning" "enable_versioning" {
  bucket = "s3-permission-read-only-akash-2025"

  versioning_configuration {
    status = "Enabled"
  }
}
