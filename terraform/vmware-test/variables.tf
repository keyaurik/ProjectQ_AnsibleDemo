#####################################################################
##
##      Created 1/15/19 by ucdpadmin. For Cloud aws-chadh for vmware-test
##
#####################################################################

variable "user" {
  type = "string"
  description = "Generated"
}

variable "password" {
  type = "string"
  description = "Generated"
}

variable "vsphere_server" {
  type = "string"
  description = "Generated"
}

variable "allow_unverified_ssl" {
  type = "string"
  description = "Generated"
}

variable "virtual_machine_name" {
  type = "string"
  description = "Virtual machine name for virtual_machine"
}

variable "virtual_machine_number_of_vcpu" {
  type = "string"
  description = "Number of virtual cpu's."
}

variable "virtual_machine_memory" {
  type = "string"
  description = "Memory allocation."
}

variable "virtual_machine_disk_name" {
  type = "string"
  description = "The name of the disk. Forces a new disk if changed. This should only be a longer path if attaching an external disk."
}

variable "virtual_machine_disk_size" {
  type = "string"
  description = "The size of the disk, in GiB."
}

variable "virtual_machine_template_name" {
  type = "string"
  description = "Generated"
}

variable "virtual_machine_datacenter_name" {
  type = "string"
  description = "Generated"
}

variable "virtual_machine_datastore_name" {
  type = "string"
  description = "Generated"
}

variable "virtual_machine_resource_pool" {
  type = "string"
  description = "Resource pool."
}

variable "virtual_disk_size" {
  type = "string"
  description = "Generated"
}

variable "virtual_disk_vmdk_path" {
  type = "string"
  description = "Generated"
}

variable "virtual_disk_datacenter_name" {
  type = "string"
  description = "The name of the datacenter in which to create the disk. Can be omitted when when ESXi or if there is only one datacenter in your infrastructure."
}

variable "virtual_disk_datastore_name" {
  type = "string"
  description = "The name of the datastore in which to create the disk."
}

variable "virtual_disk_disk_type" {
  type = "string"
  description = "The type of disk to create. Can be one of eagerZeroedThick, lazy, or thin. Default: eagerZeroedThick."
  default = "eagerZeroedThick"
}

variable "virtual_disk_disk_label" {
  type = "string"
  description = "Generated"
}

variable "virtual_disk_unit_number" {
  type = "string"
  description = "The disk number on the SCSI bus. The maximum value for this setting is the value of scsi_controller_count times 15, minus 1 (so 14, 29, 44, and 59, for 1-4 controllers respectively). The default is 0, for which one disk must be set to. Duplicate unit numbers are not allowed."
}

