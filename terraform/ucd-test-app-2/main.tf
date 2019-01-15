#####################################################################
##
##      Created 1/15/19 by ucdpadmin. For Cloud aws-chadh for ucd-test-app-2
##
#####################################################################

## REFERENCE {"aws_network":{"type": "aws_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "aws" {
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

resource "aws_instance" "aws-test" {
  ami = "${var.aws-test_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.aws-test_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  connection {
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
  }
  provisioner "ucd" {
    agent_name      = "${var.aws-test_agent_name}.${random_id.aws-test_agent_id.dec}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
    curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.aws-test_agent_name}.${random_id.aws-test_agent_id.dec} -X DELETE
EOT
}
  tags {
    Name = "${var.aws-test_name}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "ucd_component_mapping" "ucd_blueprint_designer_test" {
  component = "ucd_blueprint_designer_test"
  description = "ucd_blueprint_designer_test Component"
  parent_id = "${ucd_agent_mapping.aws-test_agent.id}"
}

resource "random_id" "aws-test_agent_id" {
  byte_length = 8
}

resource "ucd_component_process_request" "ucd_blueprint_designer_test" {
  component = "ucd_blueprint_designer_test"
  environment = "${ucd_environment.environment.id}"
  process = "deploy"
  resource = "${ucd_component_mapping.ucd_blueprint_designer_test.id}"
  version = "LATEST"
}

resource "ucd_resource_tree" "resource_tree" {
  base_resource_group_name = "Base Resource for environment ${var.environment_name}"
}

resource "ucd_environment" "environment" {
  name = "${var.environment_name}"
  application = "ucd_blueprint_designer_test_app"
  base_resource_group ="${ucd_resource_tree.resource_tree.id}"
  component_property {
      component = "ucd_blueprint_designer_test"
      name = "test"
      value = ""
      secure = false
  }
}

resource "ucd_agent_mapping" "aws-test_agent" {
  depends_on = [ "aws_instance.aws-test" ]
  description = "Agent to manage the aws-test server"
  agent_name = "${var.aws-test_agent_name}.${random_id.aws-test_agent_id.dec}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}