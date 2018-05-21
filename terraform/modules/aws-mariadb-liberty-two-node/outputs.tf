#####################################################################
##
##      Created 5/14/18 by ucdpadmin. for aws-mysql-liberty-two-node
##
#####################################################################

# Web server IP address
output "web_server_ip_address" {
  value = "${aws_instance.web-server.public_ip}"
}

# DB server IP address
output "db_server_ip_address" {
  value = "${aws_instance.db-server.public_ip}"
}

# Encoded TLS private key
output "tls-private-key" {
  value = "${base64encode(tls_private_key.ssh.private_key_pem)}"
}

# Web server user
output "web-server-user" {
  value = "${var.web-server-user}"
}

# DB server user
output "db-server-user" {
  value = "${var.db-server-user}"
}