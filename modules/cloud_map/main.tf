# Variables that are being passed in
variable "vpc_id" {}
variable "prefix" {}

# Creating a private DNS namespace for the Jenkins controller
resource "aws_service_discovery_private_dns_namespace" "controller" {
	name        = "controller.dns"
	description = "Jenkins Controller DNS namespace"
	vpc         = var.vpc_id
}

# Creates a private DNS record with the private DNS namespace
resource "aws_service_discovery_service" "controller" {
  name = "${var.prefix}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.controller.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}