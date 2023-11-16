output "jenkins_agents_cluster" {
   description = "The ARN of the Jenkins agents cluster"
   value = aws_ecs_cluster.agents.arn
}

output "jenkins_agents_windows_cluster" {
   description = "The ARN of the Jenkins agents windows cluster"
   value = aws_ecs_cluster.agents_windows.arn
}