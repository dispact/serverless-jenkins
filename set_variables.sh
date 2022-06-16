#!/bin/bash
# General
# The AWS profile to use with Terraform
export TF_VAR_aws_profile="default"
# The region we want to deploy to
export TF_VAR_region="us-east-2"
# What we will prefix our Name tags with
export TF_VAR_prefix="jenkins-tutorial"

# AWS Endpoint
# Region specific STS endpoint
# Depending on the region, the region specific STS may not be enabled for your 
# account by default. Please check the following documentation regarding 
# which regions are enabled by default and how to enable your region
# if it is not enabled by default
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_enable-regions.html#id_credentials_region-endpoints
export TF_AWS_STS_ENDPOINT="https://sts.${TF_VAR_region}.amazonaws.com"

# VPC
# The VPC CIDR Block
export TF_VAR_vpc_cidr_block="10.0.0.0/16"
# The number of public subnets (min: 2)
export TF_VAR_public_subnets="2"
# The number of private subnets (min: 2)
export TF_VAR_private_subnets="2"
# A list of CIDR blocks for the public subnets
# This must be >= $TF_VAR_public_subnets
export TF_VAR_public_subnet_blocks='["10.0.1.0/24", "10.0.2.0/24"]'
# A list of CIDR blocks for the private subnets
# This must be >= $TF_VAR_private_subnets
export TF_VAR_private_subnet_blocks='["10.0.101.0/24", "10.0.102.0/24"]'

# ECS
# The CPU amount for the Jenkins controller 
export TF_VAR_jenkins_controller_cpu=256
# The memory amount for the Jenkins controller
export TF_VAR_jenkins_controller_mem=512
# The container port to run the Jenkins controller on
export TF_VAR_jenkins_controller_port=8080
# The container port to run the Jenkins agents on
# This will also act as the JNLP port 
export TF_VAR_jenkins_agent_port=50000

# Echo all the environment variables
echo "region: $TF_VAR_region"
echo "vpc_cidr_block: $TF_VAR_vpc_cidr_block"
echo "public_subnets: $TF_VAR_public_subnets"
echo "private_subnets: $TF_VAR_private_subnets"
echo "public_subnet_blocks: $TF_VAR_public_subnet_blocks"
echo "private_subnet_blocks: $TF_VAR_private_subnet_blocks" 
echo "jenkins_controller_cpu: $TF_VAR_jenkins_controller_cpu"
echo "jenkins_controller_mem: $TF_VAR_jenkins_controller_mem"
