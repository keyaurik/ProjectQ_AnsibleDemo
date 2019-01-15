#####################################################################
##
##      Created 1/15/19 by ucdpadmin. For Cloud aws-chadh for demo-456
##
#####################################################################

## REFERENCE {"default-vpc":{"type": "aws_reference_network"}}

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

resource "aws_instance" "web-server" {
  ami = "${var.web-server_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.web-server_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  connection {
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
  }
  provisioner "ucd" {
    agent_name      = "${var.web-server_agent_name}.${random_id.web-server_agent_id.dec}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
    curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.web-server_agent_name}.${random_id.web-server_agent_id.dec} -X DELETE
EOT
}
  tags {
    Name = "${var.web-server_name}"
  }
}

resource "aws_instance" "db-server" {
  ami = "${var.db-server_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.db-server_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  connection {
    user = "ec2-user"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
  }
  provisioner "ucd" {
    agent_name      = "${var.db-server_agent_name}.${random_id.db-server_agent_id.dec}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
    curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.db-server_agent_name}.${random_id.db-server_agent_id.dec} -X DELETE
EOT
}
  tags {
    Name = "${var.db-server_name}"
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
  parent_id = "${ucd_agent_mapping.db-server_agent.id}"
}

resource "ucd_component_mapping" "jke_db" {
  component = "jke.db"
  description = "jke.db Component"
  parent_id = "${ucd_agent_mapping.db-server_agent.id}"
}

resource "ucd_component_mapping" "WebSphere_Liberty_Profile" {
  component = "WebSphere Liberty Profile"
  description = "WebSphere Liberty Profile Component"
  parent_id = "${ucd_agent_mapping.web-server_agent.id}"
}

resource "ucd_component_mapping" "jke_war" {
  component = "jke.war"
  description = "jke.war Component"
  parent_id = "${ucd_agent_mapping.web-server_agent.id}"
}

resource "random_id" "db-server_agent_id" {
  byte_length = 8
}

resource "random_id" "web-server_agent_id" {
  byte_length = 8
}

resource "ucd_component_process_request" "MySQL_Server" {
  component = "MySQL Server"
  environment = "${ucd_environment.environment.id}"
  process = "deploy mysql 5.7"
  resource = "${ucd_component_mapping.MySQL_Server.id}"
  version = "LATEST"
}

resource "ucd_component_process_request" "jke_db" {
  depends_on = [ "ucd_component_process_request.MySQL_Server", "ucd_component_process_request.WebSphere_Liberty_Profile" ]
  component = "jke.db"
  environment = "${ucd_environment.environment.id}"
  process = "deploy"
  resource = "${ucd_component_mapping.jke_db.id}"
  version = "LATEST"
}

resource "ucd_component_process_request" "WebSphere_Liberty_Profile" {
  component = "WebSphere Liberty Profile"
  environment = "${ucd_environment.environment.id}"
  process = "deploy"
  resource = "${ucd_component_mapping.WebSphere_Liberty_Profile.id}"
  version = "LATEST"
}

resource "ucd_component_process_request" "jke_war" {
  depends_on = [ "ucd_component_process_request.jke_db" ]
  component = "jke.war"
  environment = "${ucd_environment.environment.id}"
  process = "deploy"
  resource = "${ucd_component_mapping.jke_war.id}"
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
      component = "jke.db"
      name = "ChadPropEnv"
      value = "default"
      secure = false
  }
  component_property {
      component = "WebSphere Liberty Profile"
      name = "testenv"
      value = "testme"
      secure = false
  }
  component_property {
      component = "jke.war"
      name = "JKE_DB_HOST"
      value = "${aws_instance.db-server.public_ip}"  # aws_instance
      secure = false
  }
}

resource "ucd_agent_mapping" "db-server_agent" {
  depends_on = [ "aws_instance.db-server" ]
  description = "Agent to manage the db-server server"
  agent_name = "${var.db-server_agent_name}.${random_id.db-server_agent_id.dec}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}

resource "ucd_agent_mapping" "web-server_agent" {
  depends_on = [ "aws_instance.web-server" ]
  description = "Agent to manage the web-server server"
  agent_name = "${var.web-server_agent_name}.${random_id.web-server_agent_id.dec}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}