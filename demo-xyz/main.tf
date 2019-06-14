#####################################################################
##
##      Created 6/14/19 by ucdpadmin for cloud cmh-aws. for demo-xyz
##
#####################################################################

## REFERENCE {"default-vpc":{"type": "aws_reference_network"}}

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

resource "aws_instance" "my-vm" {
  ami = "${var.my-vm_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.my-vm_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  tags {
    Name = "${var.my-vm_name}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "aws_ebs_volume" "my-vol" {
    availability_zone = "${var.availability_zone}"
    size              = "${var.my-vol_volume_size}"
}

resource "aws_volume_attachment" "my-vm_my-vol_volume_attachment" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.my-vol.id}"
  instance_id = "${aws_instance.my-vm.id}"
}


