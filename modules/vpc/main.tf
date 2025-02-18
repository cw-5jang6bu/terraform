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

  map_public_ip_on_launch = true # ✅ 퍼블릭 서브넷 설정

  tags = {
    Name                                      = "public-subnet-${count.index}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"  # ✅ EKS 클러스터에 연결됨을 표시
    "kubernetes.io/role/elb"                   = "1"       # ✅ 외부 로드밸런서 (ALB) 배포 가능
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
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
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

## ✅ NAT Gateway Route Table 관련 수정 완료

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

# ✅ 보안 그룹 설정 최적화 (순환 참조 해결)

# EKS 컨트롤 플레인 보안 그룹
resource "aws_security_group" "eks_sg" {
 vpc_id = aws_vpc.main.id

 ingress {
   from_port   = 443
   to_port     = 443
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]  # API 서버에서 노드로 접근 허용
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

# ✅ EKS 노드 그룹 보안 그룹 (컨트롤 플레인과 별도 생성)
resource "aws_security_group" "eks_node_sg" {
 vpc_id = aws_vpc.main.id

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

# ✅ EKS 컨트롤 플레인 → 노드 그룹 통신 허용
resource "aws_security_group_rule" "eks_to_nodes" {
  count                    = length(aws_security_group.eks_sg.ingress) == 0 ? 1 : 0  # ✅ 중복 방지
 type                     = "ingress"
 from_port                = 10250
 to_port                  = 10250
 protocol                 = "tcp"
 security_group_id        = aws_security_group.eks_node_sg.id
 source_security_group_id = aws_security_group.eks_sg.id
}

# ✅ EKS 노드 그룹 → 컨트롤 플레인 통신 허용
resource "aws_security_group_rule" "eks_to_cluster" {
 type                     = "ingress"
 from_port                = 443
 to_port                  = 443
 protocol                 = "tcp"
 security_group_id        = aws_security_group.eks_sg.id
 source_security_group_id = aws_security_group.eks_node_sg.id
}

# ✅ EKS 노드 간 내부 통신 허용 (Self-referential 문제 해결)
resource "aws_security_group_rule" "eks_sg_internal" {
  count = length(aws_security_group.eks_sg.ingress) == 0 ? 1 : 0  # ✅ 중복 방지
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_node_sg.id
  source_security_group_id = aws_security_group.eks_node_sg.id
}

# ✅ RDS 보안 그룹 설정 (EKS → RDS 허용)
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

# ✅ EKS -> RDS 허용
resource "aws_security_group_rule" "eks_to_rds" {
 type                     = "ingress"
 from_port                = 3306
 to_port                  = 3306
 protocol                 = "tcp"
 security_group_id        = aws_security_group.db_sg.id
 source_security_group_id = aws_security_group.eks_sg.id
}

# ✅ RDS -> EKS 허용 (필요한 경우)
resource "aws_security_group_rule" "rds_to_eks" {
 type                     = "ingress"
 from_port                = 0
 to_port                  = 65535
 protocol                 = "tcp"
 security_group_id        = aws_security_group.eks_sg.id
 source_security_group_id = aws_security_group.db_sg.id
}

# ✅ ElastiCache 보안 그룹 설정
resource "aws_security_group" "cache_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cache-sg"
  }
}


resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-sg-"
  vpc_id      = aws_vpc.main.id

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

resource "aws_security_group_rule" "lambda_to_cache" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cache_sg.id  # ✅ Redis 보안 그룹 대상
  source_security_group_id = aws_security_group.lambda_sg.id  # ✅ Lambda 보안 그룹에서 접근 허용
}

resource "aws_security_group_rule" "cache_to_lambda" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id  # ✅ Lambda 보안 그룹 대상
  source_security_group_id = aws_security_group.cache_sg.id  # ✅ Redis 보안 그룹에서 응답 허용
}

resource "aws_security_group_rule" "lambda_to_rds" {
  type                     = "ingress"
  from_port                = 3306  # ✅ MySQL (Aurora MySQL의 경우)
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id  # ✅ RDS 보안 그룹 대상
  source_security_group_id = aws_security_group.lambda_sg.id  # ✅ Lambda 보안 그룹에서 접근 허용
}

resource "aws_security_group_rule" "rds_to_lambda" {
  type                     = "ingress"
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id  # ✅ Lambda 보안 그룹 대상
  source_security_group_id = aws_security_group.db_sg.id  # ✅ RDS 보안 그룹에서 응답 허용
}

resource "aws_security_group_rule" "cache_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id  # ✅ RDS 보안 그룹 대상
  source_security_group_id = aws_security_group.cache_sg.id  # ✅ Redis 보안 그룹에서 접근 허용
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ✅ 모든 외부 트래픽 허용 (보안 강화 필요)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

