output "jenkins_controller_dns_arn" {
   description = "The Jenkins Controller DNS ARN"
   value = aws_service_discovery_service.controller.arn
}

output "jenkins_controller_dns_endpoint" {
   description = "The Jenkins Controller DNS endpoint"
   value = "${aws_service_discovery_service.controller.name}.${aws_service_discovery_private_dns_namespace.controller.name}"
}