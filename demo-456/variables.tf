#####################################################################
##
##      Created 1/15/19 by ucdpadmin. For Cloud aws-chadh for demo-456
##
#####################################################################

variable "web-server_ami" {
  type = "string"
  description = "Generated"
  default = "ami-759bc50a"
}

variable "web-server_aws_instance_type" {
  default = t2.medium
  type = "string"
  description = "Generated"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
  default = "us-east-1a"
}

variable "web-server_name" {
  type = "string"
  description = "Generated"
  default = "web456"
}

variable "aws_key_pair_name" {
  type = "string"
  description = "Generated"
  default = "key456"
}

variable "db-server_ami" {
  type = "string"
  description = "Generated"
  default = "ami-b81dbfc5"
}

variable "db-server_aws_instance_type" {
  default = t2.medium
  type = "string"
  description = "Generated"
}

variable "db-server_name" {
  type = "string"
  description = "Generated"
  default = "db456"
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
  default = "env456"
}

variable "db-server_agent_name" {
  type = "string"
  description = "Agent name"
  default = "dbagent456"
}

variable "web-server_agent_name" {
  type = "string"
  description = "Agent name"
  default = "webagent456"
}

