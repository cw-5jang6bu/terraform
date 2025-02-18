resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-sg-"
  vpc_id      = var.vpc_id

  # Lambda에서 ElastiCache Redis에 접근을 허용하는 인바운드 규칙
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [
      aws_security_group.redis_sg.id  # ElastiCache Redis의 보안 그룹을 참조
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lambda Security Group"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "redis-security-group"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  # Redis에서 Lambda에 접근을 허용하는 인바운드 규칙
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [
      aws_security_group.lambda_sg.id  # Lambda의 보안 그룹을 참조
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Redis Security Group"
  }
}