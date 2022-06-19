#!/bin/bash
#############
## General ##
#############
# The AWS profile to use with Terraform
aws_profile = "default"
# The region we want to deploy to
region = "us-east-2"
# What we will prefix our Name tags with
prefix = "jenkins-tutorial"

#########
## VPC ##
#########
# The VPC CIDR Block
vpc_cidr_block = "10.0.0.0/16"
# The number of public subnets (min: 2)
public_subnets = "2"
# The number of private subnets (min: 2)
private_subnets = "2"
# A list of CIDR blocks for the public subnets
# This must be > =  $TF_VAR_public_subnets
public_subnet_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
# A list of CIDR blocks for the private subnets
# This must be > =  $TF_VAR_private_subnets
private_subnet_blocks = ["10.0.101.0/24", "10.0.102.0/24"]

#########
## ECS ##
#########
# The CPU amount for the Jenkins controller 
jenkins_controller_cpu = 256
# The memory amount for the Jenkins controller
jenkins_controller_mem = 512
# The container port to run the Jenkins controller on
jenkins_controller_port = 8080
# The container port to run the Jenkins agents on
# This will also act as the JNLP port 
jenkins_agent_port = 50000