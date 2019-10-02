#####################################################################
##
##      Created 10/2/19 by ucdpadmin for cloud aws-brad. for aws-single-vm
##
#####################################################################

## REFERENCE {"aws_network":{"type": "aws_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "aws" {
  version = "~> 1.8"
}


data "aws_subnet" "subnet" {
  vpc_id = "${var.vpc_id}"
  availability_zone = "${var.availability_zone}"
}

data "aws_security_group" "group_name" {
  name = "${var.group_name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_instance" "aws-instance" {
  count = "${var.instance_count}"
  ami      = "${var.ansible-runtime-host_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.instance_name}-${count.index}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}