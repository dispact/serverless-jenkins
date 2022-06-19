output "jenkinsExecutionRole" {
   description = "ARN of the Jenkins Execution Role"
   value = aws_iam_role.jenkinsExecutionRole.arn
}