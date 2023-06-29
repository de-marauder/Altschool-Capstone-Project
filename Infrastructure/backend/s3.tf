provider "aws" {
  region = var.region
}


resource "aws_s3_bucket" "example" {
  bucket = var.s3_bucket

  tags = {
    Name        = "Tf statefile bucket"
    Environment = "production"
  }
}