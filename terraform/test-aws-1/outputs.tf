#####################################################################
##
##      Created 9/25/18 by ucdpadmin. For Cloud AWS-SPB for test-aws-1
##
#####################################################################

output "aws_instance.jke-web / public_ip" {
  value = "${aws_instance.jke-web.public_ip}"
}

output "aws_instance.jke-db / public_ip" {
  value = "${aws_instance.jke-db.public_ip}"
}

output "jke_app_url" {
  value = "http://${aws_instance.jke-web.public_ip}:9080"
}