#####################################################################
##
##      Created 10/2/19 by ucdpadmin for cloud aws-brad. for aws-single-vm
##
#####################################################################

#####################################################################
##
##      Created 5/14/18 by ucdpadmin. for aws-mysql-liberty-two-node
##
#####################################################################

# Web server IP address
output "ip_addresses" {
  value = ["${aws_instance.aws-instance.*.public_ip}"]
}

# Encoded TLS private key
output "tls-private-key" {
  value = "${base64encode(tls_private_key.ssh.private_key_pem)}"
}

# Web server user
output "web-server-user" {
  value = "${var.instance_user}"
}
