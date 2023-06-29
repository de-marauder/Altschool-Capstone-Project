provider "aws" {
  region = var.region
}

# Save state_file in an S3 bucket
# terraform {
#   backend "s3" {
#     bucket         = var.s3_bucket
#     key            = "terraform.tfstate"
#     region         = "eu-west-2"
#   }
# }