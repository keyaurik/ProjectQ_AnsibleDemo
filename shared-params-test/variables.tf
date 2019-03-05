#####################################################################
##
##      Created 3/5/19 by admin. For Cloud cmh-vra for shared-params-test
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

variable "aws_instance_ami" {
  type = "string"
  description = "Generated"
}

variable "aws_instance_aws_instance_type" {
  type = "string"
  description = "Generated"
}

variable "availability_zone" {
  type = "string"
  description = "Generated"
}

variable "aws_instance_name" {
  type = "string"
  description = "Generated"
}

variable "aws_key_pair_name" {
  type = "string"
  description = "Generated"
}

variable "testmapvar1" {
  type = "map"

  default = {
    development = "dev"
    staging = "staging"
    preprod = "preprod"
  }

}

variable "testmap2" {
  type = "map"

  default = {
    key1 = "dev"
    key2 = "staging"
    key3 = "preprod"
  }

}

