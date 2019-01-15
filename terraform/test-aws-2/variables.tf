#####################################################################
##
##      Created 1/15/19 by ucdpadmin. For Cloud aws-chadh for test-aws-2
##
#####################################################################

variable "jke-web_ami" {
  type = "string"
  description = "Generated"
}

variable "jke-web_aws_instance_type" {
  type = "string"
  description = "Generated"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
}

variable "jke-web_name" {
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

variable "environment_name" {
  type = "string"
  description = "Environment name"
}

variable "jke-web_agent_name" {
  type = "string"
  description = "Agent name"
}


