output "jenkins_agents_cluster" {
   description = "The ARN of the Jenkins agents cluster"
   value = aws_ecs_cluster.agents.arn
}