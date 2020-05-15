## Terraform outputs

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

# Encoded TLS private key
output "tls-private-key" {
  value = "${base64encode(tls_private_key.ssh.private_key_pem)}"
}

# VM user
output "web-server-user" {
  value = "${var.vm_user}"
}

# Instance name
output "Instance name" {
  value = "${var.instance_name}"
}

