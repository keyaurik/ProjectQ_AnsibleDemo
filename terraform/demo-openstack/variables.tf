#####################################################################
##
##      Created 11/14/19 by admin. for demo-openstack
##
#####################################################################

variable "instance_name" {
  type = "string"
  description = "Generated"
}

variable "openstack_image_name" {
  type = "string"
  description = "Generated"
}

variable "openstack_flavor_name" {
  type = "string"
  description = "Generated"
}

variable "openstack_key_pair_name" {
  type = "string"
  description = "Generated"
}

variable "openstack_network" {
  type = "string"
  description = "Generated"
}

variable "instance_connection_user" {
  type = "string"
  default = "root"
}

