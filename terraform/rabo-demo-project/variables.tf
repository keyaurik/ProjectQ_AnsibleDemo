#####################################################################
##
##      Created 10/17/18 by ucdpadmin. For Cloud aws-chadh for rabo-demo-project
##
#####################################################################

variable "aws_access_id" {
  type = "string"
  description = "Generated"
}

variable "aws_secret_key" {
  type = "string"
  description = "Generated"
}

variable "region" {
  type = "string"
  description = "Generated"
}

variable "rabo-web-server_ami" {
  type = "string"
  description = "Generated"
}

variable "rabo-web-server_aws_instance_type" {
  type = "string"
  description = "Generated"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
}

variable "rabo-web-server_name" {
  type = "string"
  description = "Generated"
}

variable "aws_key_pair_name" {
  type = "string"
  description = "Generated"
}

variable "vpc_id" {
  type = "string"
  description = "Generated"
}

variable "rabo-db-server_ami" {
  type = "string"
  description = "Generated"
}

variable "rabo-db-server_aws_instance_type" {
  type = "string"
  description = "Generated"
}

variable "rabo-db-server_name" {
  type = "string"
  description = "Generated"
}

variable "group_name" {
  type = "string"
  description = "Generated"
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

variable "private_key" {
  type = "string"
  description = "Generated"
}

variable "environment_name" {
  type = "string"
  description = "Environment name"
}

variable "rabo-db-server_agent_name" {
  type = "string"
  description = "Agent name"
}


