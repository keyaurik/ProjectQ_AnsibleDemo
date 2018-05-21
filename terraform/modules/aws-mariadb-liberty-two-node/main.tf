#####################################################################
##
##      Created 5/14/18 by ucdpadmin. for aws-mysql-liberty-two-node
##
#####################################################################

## REFERENCE {"default-vpc":{"type": "aws_reference_network"}}


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

resource "aws_instance" "db-server" {
  ami = "${var.db-server_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.db-server_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.db-server_name}"
  }
}

resource "aws_instance" "web-server" {
  ami = "${var.web-server_ami}"
  key_name = "${aws_key_pair.auth.id}"
  instance_type = "${var.web-server_aws_instance_type}"
  availability_zone = "${var.availability_zone}"
  subnet_id  = "${data.aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.group_name.id}"]
  tags {
    Name = "${var.web-server_name}"
  }
}

# Random string to key names
resource "random_pet" "env_id" {
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "aws_key_pair" "auth" {
    key_name   = "awskey-demo-${random_pet.env_id.id}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "null_resource" "install-java" {
  provisioner "file" {
    destination = "/tmp/install_java.sh"
    content     = <<EOT
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
LOGFILE="/var/log/install_java.log"
echo "---Installing java---" | tee -a $LOGFILE 2>&1
apt-get update                         >> $LOGFILE 2>&1 || { echo "---Failed to update apt-get system---" | tee -a $LOGFILE; exit 1; }
apt-get install openjdk-8-jdk -y      >> $LOGFILE 2>&1 || { echo "---Failed to install java---" | tee -a $LOGFILE; exit 1; }
echo "---Done---" | tee -a $LOGFILE 2>&1
EOT
  }
  provisioner "remote-exec" {
     inline = [
        "chmod +x /tmp/install_java.sh; sudo bash /tmp/install_java.sh"
      ]
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"  # tls_private_key
    host = "${aws_instance.web-server.public_ip}"  # aws_instance
  }
}

resource "null_resource" "install-mariadb" {
  connection {
    user = "${var.db-server-user}"
    host = "${aws_instance.db-server.public_ip}"
    private_key = "${tls_private_key.ssh.private_key_pem}"
  }
  provisioner "file" {
    destination = "/tmp/install_mariadb.sh"
    content     = <<EOT
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
EOT
  }
  provisioner "remote-exec" {
     inline = [
        "chmod +x /tmp/install_mariadb.sh; sudo bash /tmp/install_mariadb.sh"
      ]
  }
}

resource "null_resource" "install-liberty" {
  depends_on = [ "null_resource.install-java" ]
  connection {
    user = "${var.web-server-user}"
    host = "${aws_instance.web-server.public_ip}"
    private_key = "${tls_private_key.ssh.private_key_pem}"
  }
  provisioner "file" {
    source      = "files/wlp-developers-runtime-8.5.5.3.jar"
    destination = "/tmp/wlp-developers-runtime-8.5.5.3.jar"
  }
  provisioner "file" {
    destination = "/tmp/install_liberty.sh"
    content     = <<EOT
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
LOGFILE="/var/log/install_liberty.log"
echo "---Installing liberty---" | tee -a $LOGFILE 2>&1
java -jar /tmp/wlp-developers-runtime-8.5.5.3.jar --acceptLicense /opt/was/liberty    >> $LOGFILE 2>&1 || { echo "---Failed to install liberty---" | tee -a $LOGFILE; exit 1; }
echo "---Done---" | tee -a $LOGFILE 2>&1
EOT
  }
  provisioner "remote-exec" {
     inline = [
        "chmod +x /tmp/install_liberty.sh; sudo bash /tmp/install_liberty.sh"
      ]
  }

}

