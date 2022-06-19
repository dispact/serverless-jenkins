output "jenkins_log_group" {
   description = "The name of the Jenkins CloudWatch log group"
   value = aws_cloudwatch_log_group.jenkins_logs.name
}

output "jenkins_controller_log_stream" {
   description = "The name of the Jenkins controller log stream"
   value = aws_cloudwatch_log_stream.jenkins_controller_log_stream.name
}

output "jenkins_agent_log_stream" {
   description = "The name of the Jenkins agent log stream"
   value = aws_cloudwatch_log_stream.jenkins_agent_log_stream.name
}