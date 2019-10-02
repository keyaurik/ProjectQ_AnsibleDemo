#####################################################################
##
##      Created 10/2/19 by ucdpadmin for cloud aws-brad. for install-ansible-runtime
##
#####################################################################

variable "connection_user" {
  type = "string"
  default = "root"
}

variable "connection_private_key" {
  type = "string"
  default = "key_value"
}

variable "connection_host" {
  type = "string"
}

