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

# Public Route Table 생성 (IGW 연결)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# Public Subnet이 IGW를 통해 인터넷 연결되도록 설정
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Public Subnet 연결
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway용 Elastic IP (AZ마다 1개씩 생성)
resource "aws_eip" "nat" {
  count  = length(aws_subnet.public)
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]
}

# AZ별 NAT Gateway 생성
resource "aws_nat_gateway" "nat" {
  count         = length(aws_subnet.public)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_eip.nat]

  tags = {
    Name = "eks-nat-gateway-${count.index}"
  }
}

# AZ별 Private Route Table 생성 (각 AZ의 NAT Gateway와 연결)
resource "aws_route_table" "private_nat" {
  count  = length(aws_subnet.private_eks)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "private-nat-route-table-${count.index}"
  }
}

# Private EKS Subnet을 NAT Gateway와 연결
resource "aws_route_table_association" "private_eks" {
  count          = length(aws_subnet.private_eks)
  subnet_id      = aws_subnet.private_eks[count.index].id
  route_table_id = aws_route_table.private_nat[count.index].id
}

# Private DB Subnet 전용 Route Table (인터넷 차단)
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-db-route-table"
  }
}

# Private DB Subnet 연결 (인터넷 연결 없음)
resource "aws_route_table_association" "private_db" {
  count          = length(aws_subnet.private_db)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}

# Public Subnet 생성 (각 AZ에 1개씩)
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private Subnet 생성 (EKS + ElastiCache)
resource "aws_subnet" "private_eks" {
  count             = length(var.private_subnet_eks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_eks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-eks-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private Subnet 생성 (DB 전용)
resource "aws_subnet" "private_db" {
  count             = length(var.private_subnet_db)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_db[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-db-subnet-${count.index}"
  }
}

# ✅ EKS 보안 그룹 (Worker Nodes용)
resource "aws_security_group" "eks_sg" {
  name        = "eks-sg"
  description = "Security Group for EKS Worker Nodes"
  vpc_id      = aws_vpc.main.id
}

# ✅ RDS 보안 그룹
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security Group for RDS"
  vpc_id      = aws_vpc.main.id
}

# ✅ ElastiCache 보안 그룹
resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "Security Group for ElastiCache"
  vpc_id      = aws_vpc.main.id
}

# ✅ EKS → RDS (MySQL 3306) 허용 (egress만 필요)
resource "aws_security_group_rule" "eks_to_rds_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_sg.id
  source_security_group_id = aws_security_group.rds_sg.id
  description              = "Allow EKS to access RDS MySQL"
}

# ✅ EKS → Redis (6379) 허용 (egress만 필요)
resource "aws_security_group_rule" "eks_to_redis" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_sg.id
  source_security_group_id = aws_security_group.elasticache_sg.id
  description              = "Allow EKS to access Redis"
}

# ✅ RDS → Redis (6379) 허용 (egress만 필요)
resource "aws_security_group_rule" "rds_to_redis" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.elasticache_sg.id
  description              = "Allow RDS to access Redis"
}

# ✅ EKS가 인터넷으로 나갈 수 있도록 NAT Gateway 허용 (EKS가 인터넷 연결 필요 시)
resource "aws_security_group_rule" "eks_egress_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow EKS worker nodes to access the Internet via NAT Gateway"
}

# ✅ EKS API 서버와의 통신을 위한 보안 그룹 규칙 추가 (kubectl용)
resource "aws_security_group_rule" "eks_api_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_sg.id
  cidr_blocks       = ["0.0.0.0/0"]  # 보안을 위해 특정 IP로 제한 가능
  description       = "Allow kubectl access to EKS API server"
}

# EKS Control Plane -> Worker Node (다양한 포트 필요)
resource "aws_security_group_rule" "controlplane_to_worker" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_sg.id
  source_security_group_id = aws_security_group.eks_sg.id  # 혹은 EKS cluster SG
  description              = "Allow EKS Control Plane to communicate with nodes"
}


