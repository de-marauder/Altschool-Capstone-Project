provider "aws" {
  region = var.region
}

# Save state_file in an S3 bucket
terraform {
  backend "s3" {
    bucket         = "altschool-capstone-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
  }
}