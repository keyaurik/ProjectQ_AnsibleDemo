#####################################################################
##
##      Created 10/1/19 by ucdpadmin for cloud aws-brad. for aws-two-node
##
#####################################################################

variable "ami" {
  type = "string"
  description = "Generated"
  default = "ami-b81dbfc5"
}

variable "instance_name" {
  type = "string"
  description = "Generated"
  default = "single-vm"
}

variable "instance_type" {
  type = "string"
  description = "Generated"
  default = "t2.medium"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
  default = "us-east-1a"
}

variable "aws_key_pair_name" {
  type = "string"
  description = "Generated"
  default = "demo-key"
}

variable "vpc_id" {
  type = "string"
  description = "Generated"
  default = "vpc-6c51be09"
}

variable "security_group_name" {
  type = "string"
  description = "Generated"
  default = "ucdev_secgroup_nva"
}

variable "vm_user" {
  type = "string"
  default = "ubuntu"
}

