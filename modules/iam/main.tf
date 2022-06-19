# This is the AWS managed policy: AmazonECSTaskExecutionRolePolicy
data "aws_iam_policy" "aws_ecs_task_execution_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# This is the IAM policy that providers Jenkins
# with the necessary permissions
resource "aws_iam_policy" "jenkins_policy" {
   name     = "jenkinsPolicy"
   policy   = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
         {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
               "ecs:ListClusters",
               "ecs:ListTaskDefinitions",
               "ecs:ListContainerInstances",
               "ecs:RunTask",
               "ecs:StopTask",
               "ecs:DescribeTasks",
               "ecs:DescribeContainerInstances",
               "ecs:DescribeTaskDefinition",
               "ecs:RegisterTaskDefinition",
               "ecs:DeregisterTaskDefinition",
               "iam:GetRole",
               "iam:PassRole"
            ],
            "Resource": "*"
         }
      ]
   })
}

# This is the Jenkins Execution Role
# The AWS managed AmazonECSTaskExecutionRolePolicy and
# the Jenkins Policy are both attached to this role
resource "aws_iam_role" "jenkinsExecutionRole" {
   name                 = "jenkinsExecutionRole"
   assume_role_policy   = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
         {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
               "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
         }
      ]
   })

   managed_policy_arns = [
      data.aws_iam_policy.aws_ecs_task_execution_policy.arn, 
      aws_iam_policy.jenkins_policy.arn
   ]
}