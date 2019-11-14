#####################################################################
##
##      Created 11/14/19 by admin. for demo-openstack
##
#####################################################################

## REFERENCE {"openstack_network":{"type": "openstack_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "openstack" {
  version = "~> 1.2"
}


resource "openstack_compute_instance_v2" "instance" {
  name      = "${var.instance_name}"
  image_name  = "${var.openstack_image_name}"
  flavor_name = "${var.openstack_flavor_name}"
  key_pair  = "${openstack_compute_keypair_v2.auth.id}"
  security_groups = ["${openstack_networking_secgroup_v2.group_name.id}"]
  connection {
    type = "ssh"
    user = "${var.instance_connection_user}"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
  }
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
  cidr       = "TODO"
  ip_version = 4
}

resource "openstack_networking_port_v2" "port" {
  name               = "port"
  network_id = "${var.openstack_network.id}"
  admin_state_up     = "true"
  fixed_ip {
    subnet_id  = "${openstack_networking_subnet_v2.subnet.id}"
    ip_address = "TODO"
  }
}

resource "openstack_blockstorage_volume_v2" "volume" {
  region      = "default"
  name        = "volume"
  size        = 8
}

resource "openstack_compute_volume_attach_v2" "instance_volume_volume" {
  instance_id = "${openstack_compute_instance_v2.instance.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.volume.id}"
}

resource "openstack_networking_secgroup_v2" "group_name" {
  name        = "group_name"
  description = "TODO"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.group_name.id}"
}

