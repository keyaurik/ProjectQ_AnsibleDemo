#####################################################################
##
##      Created 3/13/18 by ucdpadmin. for multi-cloud-mysql-liberty
##
#####################################################################

# SoftLayer public and private vlans
## REFERENCE {"softlayer-vlan":{"type": "ibm_reference_network"}}

# Default AWS VPC
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

provider "ibm" {
  softlayer_username = "${var.ibm_sl_username}"
  softlayer_api_key  = "${var.ibm_sl_api_key}"
  version = "~> 0.7"
}

data "aws_subnet" "subnet" {
  vpc_id = "${var.vpc_id}"
  availability_zone = "${var.web-server_availability_zone}"
}

data "aws_security_group" "group_name" {
  name = "${var.group_name}"
  vpc_id = "${var.vpc_id}"
}

# Create a new SSH key pair to connect to virtual machines
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

# Random string to use for environment and agent names
resource "random_pet" "env_id" {
}

# Create new AWS key pair
resource "aws_key_pair" "aws_temp_public_key" {
  key_name   = "jke-awskey-temp-demo-${random_pet.env_id.id}"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

# Create a keypair for the new private key in IBM Cloud
resource "ibm_compute_ssh_key" "ibm_cloud_temp_public_key" {
  label   = "jke-ibmkey-temp-demo-${random_pet.env_id.id}"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

# JKE Application Web Server - AWS
resource "aws_instance" "web-server" {
  ami = "${var.web-server_ami}"
  key_name = "${aws_key_pair.aws_temp_public_key.id}"
  instance_type = "${var.web-server_aws_instance_type}"
  availability_zone = "${var.web-server_availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.web-server_name}"
  }
  connection {
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    host = "${self.public_ip}"
  }
}

# JKE Application DB Server - SoftLayer
resource "ibm_compute_vm_instance" "db-server" {
  cores       = 1
  memory      = 1024
  domain      = "${var.vm_instance_domain}"
  hostname    = "${var.vm_instance_hostname}"
  datacenter  = "${var.vm_instance_datacenter}"
  ssh_key_ids             = ["${ibm_compute_ssh_key.ibm_cloud_temp_public_key.id}"]
  os_reference_code = "${var.vm_instance_os_reference_code}"
  public_vlan_id       = "${var.softlayer-vlan_public_vlan_id}"
  private_vlan_id       = "${var.softlayer-vlan_private_vlan_id}"
  connection {
    user = "root"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    host = "${self.ipv4_address}"
  }
}


##############################################################
# Install Java
##############################################################
resource "null_resource" "install_java" {
  # Specify the ssh connection
  connection {
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    host = "${aws_instance.web-server.public_ip}"
  }

  # Create the installation script
  provisioner "file" {
    content = <<EOF
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
LOGFILE="/var/log/install_java.log"
echo "---Installing java---" | tee -a $LOGFILE 2>&1
apt-get update                         >> $LOGFILE 2>&1 || { echo "---Failed to update apt-get system---" | tee -a $LOGFILE; exit 1; }
apt-get install openjdk-8-jdk -y      >> $LOGFILE 2>&1 || { echo "---Failed to install java---" | tee -a $LOGFILE; exit 1; }
echo "---Done---" | tee -a $LOGFILE 2>&1
EOF

    destination = "/tmp/install_java.sh"
  }

  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_java.sh; sudo bash /tmp/install_java.sh",
    ]
  }
}

##############################################################
# Install Liberty
##############################################################
resource "null_resource" "install_liberty" {
  depends_on = [ "null_resource.install_java" ]
  # Specify the ssh connection
  connection {
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    host = "${aws_instance.web-server.public_ip}"
  }

# TODO find a better destination for this file and use version variable?
  provisioner "file" {
    source      = "files/wlp-developers-runtime-8.5.5.3.jar"
    destination = "/tmp/wlp-developers-runtime-8.5.5.3.jar"
  }

  # Create the installation script
  provisioner "file" {
    content = <<EOF
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
LOGFILE="/var/log/install_liberty.log"
echo "---Installing liberty---" | tee -a $LOGFILE 2>&1
java -jar /tmp/wlp-developers-runtime-8.5.5.3.jar --acceptLicense /opt/was/liberty    >> $LOGFILE 2>&1 || { echo "---Failed to install liberty---" | tee -a $LOGFILE; exit 1; }
echo "---Done---" | tee -a $LOGFILE 2>&1
EOF

    destination = "/tmp/install_liberty.sh"
  }

  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_liberty.sh; sudo bash /tmp/install_liberty.sh",
    ]
  }
}

##############################################################
# Install MariaDB
##############################################################
resource "null_resource" "install_mariadb" {
  # Specify the ssh connection
  connection {
    user        = "root"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    host        = "${ibm_compute_vm_instance.db-server.ipv4_address}"
  }

  # Create the installation script
  provisioner "file" {
    content = <<EOF
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
LOGFILE="/var/log/install_mariadb.log"
echo "---Installing mariadb---" | tee -a $LOGFILE 2>&1
yum clean all                             >> $LOGFILE 2>&1 || { echo "---Failed to update yum system---" | tee -a $LOGFILE; exit 1; }
yum -y install mariadb-server mariadb     >> $LOGFILE 2>&1 || { echo "---Failed to install mariadb---" | tee -a $LOGFILE; exit 1; }
systemctl enable mariadb                  >> $LOGFILE 2>&1 || { echo "---Failed to enable mariadb---" | tee -a $LOGFILE; exit 1; }
systemctl start mariadb                   >> $LOGFILE 2>&1 || { echo "---Failed to start mariadb---" | tee -a $LOGFILE; exit 1; }
systemctl status mariadb                  >> $LOGFILE 2>&1 || { echo "---Failed to verify status of mariadb---" | tee -a $LOGFILE; exit 1; }
echo "---Done---" | tee -a $LOGFILE 2>&1
EOF

    destination = "/tmp/install_mariadb.sh"
  }

  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_mariadb.sh; sudo bash /tmp/install_mariadb.sh",
    ]
  }
}
