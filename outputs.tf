output "jenkins_alb_dns" {
   description = "The public DNS of the Jenkins ALB"
   value = module.elb.alb_dns
}