variable "region" {
  type        = string
  description = "Region"
  default = "eu-west-2"
}

variable "av_zone1" {
  type        = string
  description = "Availability zone1"
  default = "eu-west-2a"
}

variable "av_zone2" {
  type        = string
  description = "Availability zone2"
  default = "eu-west-2b"
}

variable "instance_type" {
  type        = string
  description = "Type of instance used"
  default = "t2.micro"
}

variable "montoring_instance_type" {
  type        = string
  description = "Type of instance used for monitoring"
  default = "t2.medium"
}

variable "domain_name" {
  default    = "de-marauder.me"
  type        = string
  description = "Domain name"
}

variable "keypair_filename" {
  default    = "capstone-test-key"
  type        = string
  description = "capstone server private key"
}

variable "key_dir" {
  default    = "../ansible/"
  type        = string
}
variable "server_user" {
  default    = "ubuntu"
  type        = string
}
