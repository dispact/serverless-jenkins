terraform {
   required_providers {
      aws = {
         source   = "hashicorp/aws"
         version  = "4.16.0"
      }
   }

   # Required version of Terraform
   required_version = "~> 1.1.5"
}

# AWS provider with region and profile set to the
# region and aws_profile variables
provider "aws" {
   region   = var.region
   profile  = var.aws_profile
   
   endpoints {
      sts = "https://sts.${var.region}.amazonaws.com"
   }
}

# The VPC module
# Points to main.tf in modules/vpc and passes in
# all the necessary variables
module "vpc" {
   source                  = "./modules/vpc"
   prefix                  = var.prefix
   region                  = var.region
   vpc_cidr_block          = var.vpc_cidr_block
   public_subnets          = var.public_subnets
   private_subnets         = var.private_subnets
   public_subnet_blocks    = var.public_subnet_blocks
   private_subnet_blocks   = var.private_subnet_blocks
   vpc_endpoints_sg        = module.security_groups.vpc_endpoints
}

# The Securiy Group module
# Points to main.tf in modules/security_groups 
# and passes in all the necessary variables
module "security_groups" {
   source = "./modules/security_groups"
   prefix = var.prefix
   vpc_id = module.vpc.vpc_id
   jenkins_controller_port = var.jenkins_controller_port
   jenkins_agent_port = var.jenkins_agent_port
}

# The ECR module
# Points to main.tf in modules/ecr 
# and passes in all the necessary variables
module "ecr" {
   source                     = "./modules/ecr"
   jenkins_agent_port         = var.jenkins_agent_port
   jenkins_controller_port    = var.jenkins_controller_port
   jenkins_agent_cluster      = module.ecs.jenkins_agents_cluster
   jenkins_agent_sg           = module.security_groups.jenkins_agents
   jenkins_dns                = module.cloud_map.jenkins_controller_dns_endpoint
   jenkins_log_group          = module.cloudwatch.jenkins_log_group
   jenkins_agent_log_stream   = module.cloudwatch.jenkins_agent_log_stream
   jenkins_execution_role     = module.iam.jenkinsExecutionRole
   private_subnets            = module.vpc.private_subnets
}

# The EFS module
# Points to main.tf in modules/efs 
# and passes in all the necessary variables
module "efs" {
   source            = "./modules/efs"
   prefix            = var.prefix
   efs_sg            = module.security_groups.jenkins_efs
   private_subnets   = module.vpc.private_subnets
}

# The ELB module
# Points to main.tf in modules/elb 
# and passes in all the necessary variables
module "elb" {
   source         = "./modules/elb"
   prefix         = var.prefix
   jenkins_alb_sg = module.security_groups.jenkins_alb
   vpc_id         = module.vpc.vpc_id
   public_subnets = module.vpc.public_subnets
}

# The ECS module
# Points to main.tf in modules/ecs 
# and passes in all the necessary variables
module "ecs" {
   source                     = "./modules/ecs"
   prefix                     = var.prefix
   jenkins_controller_cpu     = var.jenkins_controller_cpu
   jenkins_controller_mem     = var.jenkins_controller_mem
   jenkins_controller_port    = var.jenkins_controller_port
   jenkins_agent_port         = var.jenkins_agent_port
   jenkins_repo               = module.ecr.jenkins_repo_url
   jenkins_efs                = module.efs.efs
   jenkins_efs_ap             = module.efs.efs_ap
   jenkins_alb_tg             = module.elb.alb_tg_arn
   jenkins_controller_sg      = module.security_groups.jenkins_controller
   jenkins_log_group          = module.cloudwatch.jenkins_log_group
   jenkins_log_stream         = module.cloudwatch.jenkins_controller_log_stream
   jenkins_controller_dns_arn = module.cloud_map.jenkins_controller_dns_arn
   private_subnets            = module.vpc.private_subnets
   execution_role_arn         = module.iam.jenkinsExecutionRole
}

# The CloudWatch module
# Points to main.tf in modules/cloudwatch 
# and passes in all the necessary variables
module "cloudwatch" {
   source = "./modules/cloudwatch"
   prefix = var.prefix
}

# The IAM module
# Points to main.tf in modules/iam 
module "iam" {
   source = "./modules/iam"
}

# The Cloud Map module
# Points to main.tf in modules/cloud_map 
# and passes in all the necessary variables
module "cloud_map" {
   source   = "./modules/cloud_map"
   vpc_id   = module.vpc.vpc_id
   prefix   = var.prefix
}