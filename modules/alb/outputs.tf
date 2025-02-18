output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.eks_alb.arn
}

output "alb_dns_name" {
  description = "ALB DNS 주소"
  value       = aws_lb.eks_alb.dns_name
}

output "target_group_arn" {
  description = "ALB Target Group ARN"
  value       = aws_lb_target_group.eks_target_group.arn
}
