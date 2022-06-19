output "alb_dns" {
   description = "The DNS of the ALB"
   value = aws_lb.alb.dns_name
}

output "alb_tg_arn" {
   description = "The ARN of the target group"
   value = aws_lb_target_group.tg.arn
}