#####################################################################
##
##      Created 1/15/19 by ucdpadmin. For Cloud aws-chadh for vmware-test
##
#####################################################################

terraform {
  required_version = "> 0.8.0"
}

provider "vsphere" {
  user           = "${var.user}"
  password       = "${var.password}"
  vsphere_server = "${var.vsphere_server}"

  allow_unverified_ssl = "${var.allow_unverified_ssl}"
  version = "~> 1.2"
}


data "vsphere_virtual_machine" "virtual_machine_template" {
  name          = "${var.virtual_machine_template_name}"
  datacenter_id = "${data.vsphere_datacenter.virtual_machine_datacenter.id}"
}

data "vsphere_datacenter" "virtual_machine_datacenter" {
  name = "${var.virtual_machine_datacenter_name}"
}

data "vsphere_datastore" "virtual_machine_datastore" {
  name          = "${var.virtual_machine_datastore_name}"
  datacenter_id = "${data.vsphere_datacenter.virtual_machine_datacenter.id}"
}

resource "vsphere_virtual_machine" "virtual_machine" {
  name          = "${var.virtual_machine_name}"
  datastore_id  = "${data.vsphere_datastore.virtual_machine_datastore.id}"
  num_cpus      = "${var.virtual_machine_number_of_vcpu}"
  memory        = "${var.virtual_machine_memory}"
  guest_id = "${data.vsphere_virtual_machine.virtual_machine_template.guest_id}"
  resource_pool_id = "${var.virtual_machine_resource_pool}"
  clone {
    template_uuid = "${data.vsphere_virtual_machine.virtual_machine_template.id}"
  }
  disk {
    name = "${var.virtual_machine_disk_name}"
    size = "${var.virtual_machine_disk_size}"
  }
  disk {
    attach = true
    label  = "${var.virtual_disk_disk_label}"
    path   = "${vsphere_virtual_disk.virtual_disk.vmdk_path}"
    unit_number = "${var.virtual_disk_unit_number}"
  }
}

resource "vsphere_virtual_disk" "virtual_disk" {
  size          = "${var.virtual_disk_size}"
  vmdk_path     = "${var.virtual_disk_vmdk_path}"
  datacenter    = "${var.virtual_disk_datacenter_name}"
  datastore     = "${var.virtual_disk_datastore_name}"
  type          = "${var.virtual_disk_disk_type}"
}