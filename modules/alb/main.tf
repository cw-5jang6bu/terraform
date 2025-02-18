resource "aws_lb" "eks_alb" {
  name               = var.alb_name
  internal           = false  # ✅ 외부에서 접근 가능하도록 설정 (Public ALB)
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets           = var.public_subnet_ids

  tags = {
    Name = var.alb_name
  }
}

# ✅ Target Group 생성 (EKS 서비스와 연결)
resource "aws_lb_target_group" "eks_target_group" {
  name        = "eks-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  # ✅ EKS Pod를 대상으로 지정 (EKS는 'instance'가 아닌 'ip' 사용)

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ✅ ALB Listener 생성 (HTTP 80번 포트 오픈)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.eks_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_target_group.arn
  }
}
