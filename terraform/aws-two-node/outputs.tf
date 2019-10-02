#####################################################################
##
##      Created 10/1/19 by ucdpadmin for cloud aws-brad. for aws-two-node
##
#####################################################################

output "camtags_tagsmap" {
  value = "${module.camtags.tagsmap}"
}

output "camtags_tagslist" {
  value = "${module.camtags.tagslist}"
}

# Web server IP address
output "web_server_ip_address" {
  value = "${aws_instance.web-server.public_ip}"
}

# DB server IP address
output "db_server_ip_address_with_user" {
  value = "${var.centos-user}@${aws_instance.db-server.public_ip}"
}

# Web server IP address with user
output "web_server_ip_address_with_user" {
  value = "${var.centos-user}@${aws_instance.web-server.public_ip}"
}

# DB server IP address with user and key
output "db_server_ip_address_with_user_and_key" {
  value = { "${var.centos-user}@${aws_instance.db-server.public_ip}" = "${base64encode(tls_private_key.ssh.private_key_pem)}" }
}

# Web server IP address with user and key
output "web_server_ip_address_with_user_and_key" {
  value = { "${var.centos-user}@${aws_instance.web-server.public_ip}" = "${base64encode(tls_private_key.ssh.private_key_pem)}" }
}

# DB server IP address with user
output "db_server_ip_address" {
  value = "${aws_instance.db-server.public_ip}"
}

# Encoded TLS private key
output "tls-private-key" {
  value = "${base64encode(tls_private_key.ssh.private_key_pem)}"
}

# Centos AMI user
output "web-server-user" {
  value = "${var.centos-user}"
}

