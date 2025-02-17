# VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-internet-gateway"
  }
}

# NAT Gateway용 Elastic IP (AZ 수만큼 생성)
resource "aws_eip" "nat" {
  count = min(length(aws_subnet.public), 2)  # ✅ 최대 2개까지만 생성하여 AWS 기본 제한 내에서 관리
}

# NAT Gateway 생성 (Private Subnet의 인터넷 연결용)
resource "aws_nat_gateway" "nat" {
  count         = min(length(aws_subnet.public), 2)  # ✅ Public Subnet 개수와 AWS 제한을 고려하여 NAT Gateway 배포
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "eks-nat-gateway-${count.index}"
  }
}

# Public Subnet 생성 ( 2개 생성 )
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)  # ✅ 여러 개의 서브넷을 지원
  vpc_id                  = aws_vpc.main.id
  cidr_block       = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet 생성 (EKS 용) -> 여기를 nat와 연결
resource "aws_subnet" "private_eks" {
  count             = length(var.private_subnet_eks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_eks[count.index]
  availability_zone = var.availability_zones[count.index]


  tags = {
    Name = "private-eks-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"  # ✅ EKS가 내부 로드밸런서를 사용할 수 있도록 설정
  }
}

# Private Subnet 생성 (DB & ElastiCache 용)
resource "aws_subnet" "private_db" {
  count             = length(var.private_subnet_db)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_db[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-db-subnet-${count.index}"
  }
}

# NAT Gateway와 연결되는 Route Table 생성 (NAT Gateway를 사용할 Private Subnet만 연결)
resource "aws_route_table" "private_nat_eks" {
  count  = length(aws_subnet.private_eks)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id  # ✅ 해당 AZ의 NAT Gateway와 연결
  }

  tags = {
    Name = "private-nat-route-table-${count.index}"
  }
}

# NAT Gateway 연결을 원하는 Private Subnet만 Route Table과 연결
resource "aws_route_table_association" "private_nat_eks" {
  count          = length(aws_subnet.private_eks)
  subnet_id      = aws_subnet.private_eks[count.index].id  # ✅ NAT Gateway와 연결되는 Private Subnet
  route_table_id = aws_route_table.private_nat_eks[count.index].id
}


# 보안 그룹 생성 - EKS
resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.main.id

  # ✅ EKS API 서버 → 노드 그룹 통신 허용 (Kubelet, 인증)
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  # EKS API 서버에서 모든 노드에 접근 가능
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-sg"
  }
}

# 보안 그룹 생성 - RDS
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# ✅ EKS -> RDS 허용 (보안 그룹 규칙을 따로 생성)
resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id  # ✅ RDS 보안 그룹에 적용
  source_security_group_id = aws_security_group.eks_sg.id  # ✅ EKS 보안 그룹에서 접근 허용
}

# # ✅ RDS -> EKS 허용 (필요한 경우)
# resource "aws_security_group_rule" "rds_to_eks" {
#   type                     = "ingress"
#   from_port                = 0
#   to_port                  = 65535
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_sg.id  # ✅ EKS 보안 그룹에 적용
#   source_security_group_id = aws_security_group.db_sg.id  # ✅ RDS 보안 그룹에서 접근 허용
# }

resource "aws_security_group" "eks_node_sg" {
  vpc_id = aws_vpc.main.id

  # ✅ 노드끼리 통신 허용 (내부 트래픽)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true  # ✅ 같은 SG 내에서 모든 트래픽 허용
  }

  # ✅ 컨트롤 플레인 → 노드 연결 허용 (SSH, API)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_sg.id]  # ✅ SSH 접근 허용 (관리용)
  }

  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_sg.id]  # ✅ Kubelet API 연결
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-sg"
  }
}

# # 보안 그룹 생성 - ElastiCache
# resource "aws_security_group" "cache_sg" {
#   vpc_id = aws_vpc.main.id
#
#   ingress {
#     from_port       = 6379
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [aws_security_group.eks_sg.id]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "cache-sg"
#   }
# }





