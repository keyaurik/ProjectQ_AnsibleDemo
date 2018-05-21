#####################################################################
##
##      Created 5/14/18 by ucdpadmin. for aws-mysql-liberty-two-node
##
#####################################################################

variable "db-server_ami" {
  type = "string"
  description = "Generated"
}

variable "db-server_aws_instance_type" {
  type = "string"
  description = "Generated"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
}

variable "db-server_name" {
  type = "string"
  description = "Generated"
}

variable "web-server_ami" {
  type = "string"
  description = "Generated"
}

variable "web-server_aws_instance_type" {
  type = "string"
  description = "Generated"
}

variable "web-server_name" {
  type = "string"
  description = "Generated"
}

variable "group_name" {
  type = "string"
  description = "Generated"
}

variable "vpc_id" {
  type = "string"
  description = "Generated"
}

variable "web-server-user" {
  type = "string"
  description = "Generated"
  default = "ubuntu"
}

variable "db-server-user" {
  type = "string"
  description = "Generated"
  default = "centos"
}


