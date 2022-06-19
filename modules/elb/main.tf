# Variables that we are passing in
variable "jenkins_alb_sg" {}
variable "vpc_id" {}
variable "public_subnets" {}
variable "prefix" {}

# This is the ALB
resource "aws_lb" "alb" {
   name                 = "${var.prefix}-alb"
   internal             = false
   load_balancer_type   = "application"
   # Attaching the jenkins-alb security group
   security_groups      = [var.jenkins_alb_sg]
   # Placing the ALB in all the private subnets
   subnets              = [for subnet in var.public_subnets : subnet.id]

   tags = {
      Name = "${var.prefix}-alb"
   }
}

# This is the load balancer target group
# Jekins will be associated with the target group
resource "aws_lb_target_group" "tg" {
   name        = "${var.prefix}-tg"
   target_type = "ip"
   port        = 80
   protocol    = "HTTP"
   vpc_id      = var.vpc_id

   # Health check specified to /login as that is the
   # only page that we can check without being authenticated
   # and received a 200
   health_check {
     enabled   = true
     path      = "/login"
     interval  = 300
   }

   tags = {
      Name = "${var.prefix}-tg"
   }
}

# ALB Listener. This listens for traffic to the ALB on port 80
# and sends that traffic to the target group (Jenkins)
resource "aws_lb_listener" "http" {
   load_balancer_arn = aws_lb.alb.arn
   port              = 80
   protocol          = "HTTP"

   default_action {
     type               = "forward"
     target_group_arn   = aws_lb_target_group.tg.arn
   }
}