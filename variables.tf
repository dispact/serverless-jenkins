variable "aws_profile" {
   description = "AWS profile configured on system"
}

variable "region" {
   description = "AWS Region"
}

variable "vpc_cidr_block" {
   description = "CIDR block of the VPC"
}

variable "public_subnets" {
   description = "The number of public subnets"
   default = "1"
}

variable "private_subnets" {
   description = "The number of private subnets"
   default = "1"
}

variable "public_subnet_blocks" {
   description = "List of CIDR blocks for public subnets"
   type = list
}

variable "private_subnet_blocks" {
   description = "List of CIDR blocks for private subnets"
   type = list
}

variable "jenkins_controller_cpu" {
   description = "The CPU for the Jenkins controller"
   type = number
}

variable "jenkins_controller_mem" {
   description = "The memory for the Jenkins controller"
   type = number
}

variable "jenkins_controller_port" {
   description = "The port of the Jenkins controller"
   type = number
}

variable "jenkins_agent_port" {
   description = "The port of the Jenkins agents"
   type = number
}

variable "prefix" {
   description = "AWS Resource Prefix"
   type = string
}