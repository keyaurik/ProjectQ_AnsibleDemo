#####################################################################
##
##      Created 1/15/19 by ucdpadmin. For Cloud aws-chadh for ucd-test-app-2
##
#####################################################################


variable "aws-test_ami" {
  type = "string"
  description = "Generated"
  default = "ami-759bc50a"
}

variable "aws-test_aws_instance_type" {
  type = "string"
  description = "Generated"
  default = "t2.medium"
}

variable "availability_zone" {
  type = "string"
  default = "us-east-1a"
}

variable "aws-test_name" {
  type = "string"
  description = "Generated"
  default = "test77"
}

variable "aws_key_pair_name" {
  type = "string"
  description = "Generated"
  default = "key77"
}

variable "vpc_id" {
  type = "string"
  description = "Generated"
  default = "vpc-6c51be09"
}

variable "group_name" {
  type = "string"
  description = "Generated"
  default = "ucdev_secgroup_nva"
}

variable "ucd_user" {
  type = "string"
  description = "UCD User."
  default = "admin"
}

variable "ucd_password" {
  type = "string"
  description = "UCD Password."
}

variable "ucd_server_url" {
  type = "string"
  description = "UCD Server URL."
  default = "http://54.89.250.86:9080"
}

variable "environment_name" {
  type = "string"
  description = "Environment name"
}

variable "aws-test_agent_name" {
  type = "string"
  description = "Agent name"
}


