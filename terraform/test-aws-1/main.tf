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

resource "aws_instance" "jke-web" {
  ami = "${var.jke-web_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.jke-web_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  connection {
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
  }
  provisioner "ucd" {
    agent_name      = "${var.jke-web_agent_name}.${random_id.jke-web_agent_id.dec}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
    curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.jke-web_agent_name}.${random_id.jke-web_agent_id.dec} -X DELETE
EOT
}
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
  connection {
    user = "centos"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
  }
  provisioner "ucd" {
    agent_name      = "${var.jke-db_agent_name}.${random_id.jke-db_agent_id.dec}"
    ucd_server_url  = "${var.ucd_server_url}"
    ucd_user        = "${var.ucd_user}"
    ucd_password    = "${var.ucd_password}"
  }
  provisioner "local-exec" {
    when = "destroy"
    command = <<EOT
    curl -k -u ${var.ucd_user}:${var.ucd_password} ${var.ucd_server_url}/cli/agentCLI?agent=${var.jke-db_agent_name}.${random_id.jke-db_agent_id.dec} -X DELETE
EOT
}
  tags {
    Name = "${var.jke-db_name}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_pair_name}${random_id.jke-db_agent_id.dec}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "ucd_component_mapping" "MySQL_Server" {
  component = "MySQL Server"
  description = "MySQL Server Component"
  parent_id = "${ucd_agent_mapping.jke-db_agent.id}"
}

resource "ucd_component_mapping" "jke_db" {
  component = "jke.db"
  description = "jke.db Component"
  parent_id = "${ucd_agent_mapping.jke-db_agent.id}"
}

resource "ucd_component_mapping" "WebSphere_Liberty_Profile" {
  component = "WebSphere Liberty Profile"
  description = "WebSphere Liberty Profile Component"
  parent_id = "${ucd_agent_mapping.jke-web_agent.id}"
}

resource "ucd_component_mapping" "jke_war" {
  component = "jke.war"
  description = "jke.war Component"
  parent_id = "${ucd_agent_mapping.jke-web_agent.id}"
}

resource "random_id" "jke-db_agent_id" {
  byte_length = 8
}

resource "random_id" "jke-web_agent_id" {
  byte_length = 8
}

resource "ucd_resource_tree" "resource_tree" {
  base_resource_group_name = "Base Resource for environment ${var.environment_name}"
}

resource "ucd_environment" "environment" {
  name = "${var.environment_name}-${random_id.jke-db_agent_id.dec}"
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
      value = "${aws_instance.jke-db.public_ip}"  # aws_instance
      secure = false
  }
}

resource "ucd_agent_mapping" "jke-db_agent" {
  depends_on = [ "aws_instance.jke-db" ]
  description = "Agent to manage the jke-db server"
  agent_name = "${var.jke-db_agent_name}.${random_id.jke-db_agent_id.dec}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}

resource "ucd_agent_mapping" "jke-web_agent" {
  depends_on = [ "aws_instance.jke-web" ]
  description = "Agent to manage the jke-web server"
  agent_name = "${var.jke-web_agent_name}.${random_id.jke-web_agent_id.dec}"
  parent_id = "${ucd_resource_tree.resource_tree.id}"
}

resource "ucd_application_process_request" "application_process_request" {
  depends_on = [ "ucd_component_mapping.MySQL_Server", "ucd_component_mapping.jke_db", "ucd_component_mapping.WebSphere_Liberty_Profile", "ucd_component_mapping.jke_war" ]
  application = "JKE"
  application_process = "install-hybrid-centos"
  environment = "${ucd_environment.environment.name}"
  component_version {
      component = "MySQL Server"
      version = "latest"
  }
  component_version {
      component = "jke.db"
      version = "latest"
  }
  component_version {
      component = "WebSphere Liberty Profile"
      version = "latest"
  }
  component_version {
      component = "jke.war"
      version = "latest"
  }
}