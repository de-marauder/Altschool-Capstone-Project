variable "region" {
  type        = string
  description = "Region"
  default = "eu-west-2"
}

variable "s3_bucket" {
  description = "s3_bucket"
  default = "altschool-capstone-state-bucket"
}
