output "jenkins_controller" {
   description = "ID of the Jenkins Controller SG"
   value = aws_security_group.jenkins_controller.id
}

output "jenkins_agents" {
   description = "ID of the Jenkins Agent SG"
   value = aws_security_group.jenkins_agents.id
}

output "jenkins_agents-windows" {
   description = "ID of the Jenkins Agent Windows SG"
   value = aws_security_group.jenkins_agents_windows.id
}

output "jenkins_efs" {
   description = "ID of the Jenkins EFS SG"
   value = aws_security_group.jenkins_efs.id
}

output "jenkins_alb" {
   description = "ID of the Jenkins ALB SG"
   value = aws_security_group.jenkins_alb.id
}

output "vpc_endpoints" {
   description = "ID of the VPC Endpoints SG"
   value = aws_security_group.vpc_endpoints.id
}