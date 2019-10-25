#####################################################################
##
##      Created 10/1/19 by ucdpadmin for cloud aws-brad. for aws-two-node
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

resource "aws_instance" "web-server" {
  ami = "${var.ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]

  tags = "${merge(
    module.camtags.tagsmap,
    map(
      "Name", "cmh-ans-web-1",
      "webservers", ""
    )
  )}"
  provisioner "local-exec" {
      command = "sleep 30"
  }
}

resource "aws_instance" "db-server" {
  ami = "${var.ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags = "${merge(
    module.camtags.tagsmap,
    map(
      "Name", "cmh-ans-db-1",
      "dbservers", ""
    )
  )}"
  provisioner "local-exec" {
      command = "sleep 30"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

module "camtags" {
  source  = "../Modules/camtags"
}