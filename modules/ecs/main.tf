# Variables that are being passed in
data "aws_region" "current" {}
variable "prefix" {}
variable "jenkins_controller_cpu" {}
variable "jenkins_controller_mem" {}
variable "jenkins_repo" {}
variable "jenkins_efs" {}
variable "jenkins_efs_ap" {}
variable "private_subnets" {}
variable "jenkins_alb_tg" {}
variable "jenkins_controller_sg" {}
variable "jenkins_log_group" {}
variable "jenkins_log_stream" {}
variable "execution_role_arn" {}
variable "jenkins_controller_port" {}
variable "jenkins_agent_port" {}
variable "jenkins_controller_dns_arn" {}

# This is the ECS cluster for the Jenkins controller
resource "aws_ecs_cluster" "controller" {
   name = "${var.prefix}-controller"
}

# This is the ECS cluster for the Jenkins agent
resource "aws_ecs_cluster" "agents" {
   name = "${var.prefix}-agents"
}

# ECS cluster capacity provider for the Jenkins controller cluster
resource "aws_ecs_cluster_capacity_providers" "controller" {
   cluster_name = aws_ecs_cluster.controller.name
   capacity_providers = ["FARGATE"]

   default_capacity_provider_strategy {
      base              = 1
      weight            = 100
      capacity_provider = "FARGATE"
   }
}

# ECS cluster capacity provider for the Jenkins agent cluster
resource "aws_ecs_cluster_capacity_providers" "agents" {
   cluster_name = aws_ecs_cluster.agents.name
   capacity_providers = ["FARGATE_SPOT"]

   default_capacity_provider_strategy {
      base              = 1
      weight            = 100
      capacity_provider = "FARGATE_SPOT"
   }
}

# The task definition for the Jenkins controller
# This uses a terraform template file and populates it with the
# necessary variables
resource "aws_ecs_task_definition" "jenkins_td" {
   family                  = "${var.prefix}"
   container_definitions   = templatefile(
      "${path.module}/task-definitions/jenkins.tftpl", {
         name                    = "${var.prefix}",
         image                   = var.jenkins_repo,
         cpu                     = var.jenkins_controller_cpu,
         memory                  = var.jenkins_controller_mem,
         efsVolumeName           = "${var.prefix}-efs",
         efsVolumeId             = var.jenkins_efs,
         transmitEncryption      = true,
         containerPath           = "/var/jenkins_home",
         region                  = data.aws_region.current.name
         log_group               = var.jenkins_log_group
         log_stream              = var.jenkins_log_stream
         jenkins_controller_port = var.jenkins_controller_port
         jenkins_agent_port      = var.jenkins_agent_port
      }
   )
   requires_compatibilities   = ["FARGATE"]
   network_mode               = "awsvpc"
   cpu                        = var.jenkins_controller_cpu
   memory                     = var.jenkins_controller_mem
   execution_role_arn         = var.execution_role_arn
   task_role_arn              = var.execution_role_arn

   # Setting the volume to the EFS
   volume {
      name = "${var.prefix}-efs"

      efs_volume_configuration {
         file_system_id       = var.jenkins_efs
         root_directory       = "/var/jenkins_home"
         transit_encryption   = "ENABLED"

         authorization_config {
            access_point_id = var.jenkins_efs_ap
            iam = "ENABLED"
         }
      }
   }
}

# The ECS service for the Jenkins controller
resource "aws_ecs_service" "jenkins" {
   name              = "jenkins"
   # The Jenkins Controller cluster
   cluster           = aws_ecs_cluster.controller.id
   # The Jenkins controller task definition
   task_definition   = aws_ecs_task_definition.jenkins_td.arn
   launch_type       = "FARGATE"

   desired_count                       = 1
   deployment_minimum_healthy_percent  = 0
   deployment_maximum_percent          = 100
   
   # Setting the service to run in all private subnets
   # and attached the jenkins-controller security group
   network_configuration {
      subnets           = [for subnet in var.private_subnets : subnet.id]
      security_groups   = [var.jenkins_controller_sg]
   }

   # Registering the Jenkins controller private DNS created with CloudMap
   service_registries {
      registry_arn = var.jenkins_controller_dns_arn
   }

   # Specifying the load balancer target group to put this service in
   # and what port is should be mapped to on the container
   load_balancer {
     target_group_arn   = var.jenkins_alb_tg
     container_name     = "${var.prefix}"
     container_port     = var.jenkins_controller_port
   }
}