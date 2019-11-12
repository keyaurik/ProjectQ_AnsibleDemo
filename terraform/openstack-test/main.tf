#####################################################################
##
##      Created 11/12/19 by admin. for openstack-test
##
#####################################################################

## REFERENCE {"openstack_network":{"type": "openstack_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "openstack" {
  version = "~> 1.2"
}


resource "openstack_compute_instance_v2" "test-vm" {
  name      = "${var.test-vm_name}"
  image_name  = "${var.openstack_image_name}"
  flavor_name = "${var.openstack_flavor_name}"
  key_pair  = "${openstack_compute_keypair_v2.auth.id}"
  network {
    port = "${openstack_networking_port_v2.port.id}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "openstack_compute_keypair_v2" "auth" {
    name = "${var.openstack_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "subnet"
  network_id = "${var.openstack_network.id}"
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_networking_port_v2" "port" {
  name               = "port"
  network_id = "${var.openstack_network.id}"
  admin_state_up     = "true"
  fixed_ip {
    subnet_id  = "${openstack_networking_subnet_v2.subnet.id}"
    ip_address = "192.168.199.10"
  }
}