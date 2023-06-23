variable "region" {
  type        = string
  description = "Region"
  default = "eu-west-2"
}

variable "av-zone1" {
  type        = string
  description = "Availability zone1"
  default = "eu-west-2a"
}

variable "av-zone2" {
  type        = string
  description = "Availability zone2"
  default = "eu-west-2b"
}

variable "ami" {
  type        = string
  description = "ami of the instance"
  default = "ami-01b8d743224353ffe"
}

variable "instance-type" {
  type        = string
  description = "Type of instance used"
  default = "t2.micro"
}

# Only the monitoring instance uses the t2-medium, hence we are using a different ami and instance type
variable "monitoring-ami" {
  type        = string
  description = "ami of the monitoring instance"
  default = "ami-007ec828a062d87a5"
}

variable "montoring-instance-type" {
  type        = string
  description = "Type of instance used for monitoring"
  default = "t2.midium"
}

variable "key-name" {
  type        = string
  description = "Name of the key used"
  default = "capstoneKey"
}