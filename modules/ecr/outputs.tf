output "jenkins_repo_url" {
   description = "The Jenkins controller repo URL"
   value = aws_ecr_repository.jenkins_controller_repo.repository_url
}