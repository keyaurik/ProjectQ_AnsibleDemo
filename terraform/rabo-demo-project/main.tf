#####################################################################
##
##      Created 10/17/18 by ucdpadmin. For Cloud aws-chadh for rabo-demo-project
##
#####################################################################

## REFERENCE {"default-vpc":{"type": "aws_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "aws" {
  access_key = "${var.aws_access_id}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
  version = "~> 1.8"
}

provider "ucd" {
  username       = "${var.ucd_user}"
  password       = "${var.ucd_password}"
  ucd_server_url = "${var.ucd_server_url}"
}


data "aws_subnet" "subnet" {
  vpc_id = "${var.vpc_id}"
  availability_zone = "${var.availability_zone}"
}

data "aws_security_group" "group_name" {
  name = "${var.group_name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_instance" "rabo-web-server" {
  ami = "${var.rabo-web-server_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.rabo-web-server_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.rabo-web-server_name}"
  }
}

resource "aws_instance" "rabo-db-server" {
  ami = "${var.rabo-db-server_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.rabo-db-server_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  connection {
    user = "TODO"
    private_key = "${var.private_key}"
  }
  provisioner "ucd" {
    agent_name      = "${var.rabo-db-server_agent_name}.${random_id.rabo-db-server_agent_id.dec}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
    curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.rabo-db-server_agent_name}.${random_id.rabo-db-server_agent_id.dec} -X DELETE
EOT
}
  tags {
    Name = "${var.rabo-db-server_name}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "ucd_component_mapping" "MySQL_Server" {
  component = "MySQL Server"
  description = "MySQL Server Component"
  parent_id = "${ucd_agent_mapping.rabo-db-server_agent.id}"
}

resource "random_id" "rabo-db-server_agent_id" {
  byte_length = 8
}

resource "ucd_component_process_request" "MySQL_Server" {
  component = "MySQL Server"
  environment = "${ucd_environment.environment.id}"
  process = "CHOOSE  #  deploy, deploy mysql 5.5, deploy mysql 5.7, deploy_aix, deploy_centos7"
  resource = "${ucd_component_mapping.MySQL_Server.id}"
  version = "LATEST"
}

resource "ucd_resource_tree" "resource_tree" {
  base_resource_group_name = "Base Resource for environment ${var.environment_name}"
}

resource "ucd_environment" "environment" {
  name = "${var.environment_name}"
  application = "JKE"
  base_resource_group ="${ucd_resource_tree.resource_tree.id}"
  component_property {
      component = "MySQL Server"
      name = "test2"
      value = ""
      secure = false
  }
  component_property {
      component = "MySQL Server"
      name = "test"
      value = ""
      secure = false
  }
}

resource "ucd_agent_mapping" "rabo-db-server_agent" {
  depends_on = [ "aws_instance.rabo-db-server" ]
  description = "Agent to manage the rabo-db-server server"
  agent_name = "${var.rabo-db-server_agent_name}.${random_id.rabo-db-server_agent_id.dec}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}