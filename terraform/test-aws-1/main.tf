#####################################################################
##
##      Created 9/25/18 by ucdpadmin. For Cloud AWS-SPB for test-aws-1
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

data "aws_security_group" "group_name" {
  name = "${var.group_name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_instance" "jke-web" {
  ami = "${var.jke-web_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.jke-web_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.jke-web_name}"
  }
}

resource "aws_instance" "jke-db" {
  ami = "${var.jke-db_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.jke-db_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.jke-db_name}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}