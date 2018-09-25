#####################################################################
##
##      Created 9/25/18 by ucdpadmin. For Cloud AWS-SPB for test-aws-1
##
#####################################################################

variable "jke-web_ami" {
  type = "string"
  description = "Generated"
  default = "ami-759bc50a"
}

variable "jke-web_aws_instance_type" {
  type = "string"
  description = "Generated"
  default = "t2.medium"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
  default = "us-east-1a"
}

variable "jke-web_name" {
  type = "string"
  description = "Generated"
  default = "jke-web-cmh"
}

variable "aws_key_pair_name" {
  type = "string"
  description = "Generated"
  default = "jke-web-key-cmh"
}

variable "vpc_id" {
  type = "string"
  description = "Generated"
  default = "vpc-6c51be09"
}

variable "jke-db_ami" {
  type = "string"
  description = "Generated"
}

variable "jke-db_aws_instance_type" {
  type = "string"
  description = "Generated"
  default = "t2.medium"
}

variable "jke-db_name" {
  type = "string"
  description = "Generated"
  default = "jke-db-cmh"
}

variable "group_name" {
  type = "string"
  description = "Generated"
  default = "ucdev_secgroup_nva"
}


