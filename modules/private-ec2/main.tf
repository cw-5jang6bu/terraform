resource "aws_security_group" "private_ec2" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [var.bastion_sg_id]  # Bastion에서만 SSH 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-private-ec2-sg"
  }
}

# Private Subnet에 위치하는 EC2 인스턴스
resource "aws_instance" "private_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  private_ip    = var.private_ip
  key_name      = var.key_pair
  vpc_security_group_ids = [aws_security_group.private_ec2.id]

  tags = {
    Name = "${var.vpc_name}-private-ec2"
  }
}
