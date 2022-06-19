data "aws_region" "current" {}
variable "jenkins_controller_port" {}
variable "jenkins_agent_cluster" {}
variable "jenkins_agent_port" {}
variable "jenkins_agent_sg" {}
variable "private_subnets" {}
variable "jenkins_dns" {}
variable "jenkins_log_group" {}
variable "jenkins_agent_log_stream" {}
variable "jenkins_execution_role" {}

# This is the Jenkins controller repo
resource "aws_ecr_repository" "jenkins_controller_repo" {
  name = "jenkins-controller"
}

# This is the Jenkins agent repo
resource "aws_ecr_repository" "jenkins_agent_repo" {
  name = "jenkins-agent"
}

# Grabbing the repo endpoints and setting them as local variables
locals {
  controller_repo_endpoint = split("/", aws_ecr_repository.jenkins_controller_repo.repository_url)[0]
  agent_repo_endpoint = split("/", aws_ecr_repository.jenkins_agent_repo.repository_url)[0]
}

# This is the jenkins controller configuration
# We have a jenkins.yaml.tftpl terraform template file that is populated
# with the necessary data and then outputted as jenkins.yaml
# The jenkins.yaml is picked up by Docker and used to configure Jenkins
resource "local_file" "jenkins_config" {
  content = templatefile("${path.module}/../docker/jenkins_controller/jenkins.yaml.tftpl", {
    ecs_agent_cluster       = var.jenkins_agent_cluster,
    region                  = data.aws_region.current.name,
    jenkins_controller_port = var.jenkins_controller_port
    jenkins_agent_port      = var.jenkins_agent_port,
    jenkins_agent_sg        = var.jenkins_agent_sg,
    subnets                 = "${join(",", [for subnet in var.private_subnets : subnet.id])}",
    jenkins_agent_image     = aws_ecr_repository.jenkins_agent_repo.repository_url
    jenkins_dns             = var.jenkins_dns,
    log_group               = var.jenkins_log_group,
    log_stream              = var.jenkins_agent_log_stream,
    ecs_execution_role      = var.jenkins_execution_role
  })
  filename = "${path.module}/../docker/jenkins_controller/jenkins.yaml"
}

# This is a null resource, all it does is build and push the 
# Jenkins controller image to the Jenkins controller repo
resource "null_resource" "build_and_push_image_jenkins_controller" {
  depends_on = [local_file.jenkins_config]

  provisioner "local-exec" {
    command = <<EOF
      set -ex
      echo "--- JENKINS CONTROLLER ---"
      aws ecr get-login-password --region ${data.aws_region.current.name} | \
      docker login --username AWS --password-stdin ${local.controller_repo_endpoint} && \
      docker build -t jenkins-controller ${path.module}/../docker/jenkins_controller --platform linux/amd64 && \
      docker tag jenkins-controller:latest ${aws_ecr_repository.jenkins_controller_repo.repository_url}:latest
      docker push ${aws_ecr_repository.jenkins_controller_repo.repository_url}:latest
      EOF
  }
}

# This is a null resource, all it does is build and push the 
# Jenkins agent image to the Jenkins agent repo
resource "null_resource" "build_and_push_image_jenkins_agent" {
  provisioner "local-exec" {
    command = <<EOF
      set -ex
      echo "--- JENKINS AGENT ---"
      aws ecr get-login-password --region ${data.aws_region.current.name} | \
      docker login --username AWS --password-stdin ${local.agent_repo_endpoint} && \
      docker build -t jenkins-agent ${path.module}/../docker/jenkins_agent --platform linux/amd64 && \
      docker tag jenkins-agent:latest ${aws_ecr_repository.jenkins_agent_repo.repository_url}:latest
      docker push ${aws_ecr_repository.jenkins_agent_repo.repository_url}:latest
      EOF
  }
} 