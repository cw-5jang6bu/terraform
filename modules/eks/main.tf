resource "aws_eks_cluster" "eks" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.eks_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = false # ✅ 내부에서만 접근 가능
  }

  tags = {
    Name = "eks-cluster"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# ✅ EKS 클러스터 운영에 필요한 기본 정책 연결
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_role.name
}

# ✅ EKS 노드 그룹을 추가할 수 있도록 정책 추가
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_role.name
}

# ✅ EKS가 ELB (Load Balancer)를 생성할 수 있도록 정책 추가
resource "aws_iam_role_policy_attachment" "eks_elb_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t3.medium"]  # ✅ 최소 사양 선택 (비용 절감 가능)

  scaling_config {
    desired_size = 2  # ✅ 기본 2개 노드 생성
    min_size     = 1
    max_size     = 3
  }

  remote_access {
    ec2_ssh_key = var.ssh_key_name
  }

  depends_on = [aws_eks_cluster.eks]

  tags = {
    Name = "eks-node-group"
  }
}

# ✅ EKS NodeGroup에 필요한 IAM 역할 생성
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# ✅ EKS 노드 운영을 위한 필수 정책 추가
resource "aws_iam_role_policy_attachment" "eks_node_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}




# EKS 보안 그룹 생성
# resource "aws_security_group" "eks_sg" {
#   vpc_id = var.vpc_id
#   name   = "eks-sg"
#   description = "Security group for EKS"
#
#   # ✅ EKS → RDS (MySQL)
#   egress {
#     from_port       = 3306
#     to_port         = 3306
#     protocol        = "tcp"
#     security_groups = [var.rds_sg_id]
#     description     = "Allow outbound MySQL traffic to RDS"
#   }
#   #
#   # ✅ EKS → Redis (ElastiCache)
#   egress {
#     from_port       = 6379
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [var.elasticache_sg_id]
#     description     = "Allow outbound Redis traffic to ElastiCache"
#   }
#
#
#   # ✅ EKS에서 외부로 나가는 모든 트래픽 허용 (NAT Gateway 사용)
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "eks-sg"
#   }
# }

# # ✅ EKS → ElastiCache (Redis) 통신 허용
# resource "aws_security_group_rule" "eks_to_redis" {
#   type                     = "ingress"
#   from_port                = 6379
#   to_port                  = 6379
#   protocol                 = "tcp"
#   security_group_id        = var.elasticache_sg_id
#   source_security_group_id = aws_security_group.eks_sg.id
# }
#
# # ✅ EKS → RDS (Aurora MySQL) 통신 허용
# resource "aws_security_group_rule" "eks_to_rds" {
#   type                     = "ingress"
#   from_port                = 3306
#   to_port                  = 3306
#   protocol                 = "tcp"
#   security_group_id        = var.rds_sg_id
#   source_security_group_id = aws_security_group.eks_sg.id
# }






# # EKS 클러스터 생성
# resource "aws_eks_cluster" "eks" {
#   name     = var.cluster_name
#   role_arn = aws_iam_role.eks_cluster_role.arn
#
#   vpc_config {
#     subnet_ids              = var.subnet_ids  # ✅ VPC 모듈에서 전달된 Private Subnet 사용
#     security_group_ids      = [var.security_group_id]  # ✅ VPC에서 전달된 보안 그룹 사용    endpoint_private_access = true  # ✅ 내부 통신 허용 (kubectl 등 내부 접근 가능)
#     endpoint_private_access = true # ✅ 내부 접근 가능하도록 설정
#     endpoint_public_access  = true  # ✅ 외부 접근 가능 (ArgoCD CLI 필요)
#   }
#
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_cluster_policy
#   ]
# }
#
# # EKS Node Group 생성
# resource "aws_eks_node_group" "eks_nodes" {
#   cluster_name    = aws_eks_cluster.eks.name
#   node_group_name = "${var.cluster_name}-node-group"
#   node_role_arn   = aws_iam_role.eks_node_role.arn
#   subnet_ids      = var.subnet_ids  # ✅ Private Subnet 사용
#   instance_types = ["t3.medium"]  # ✅ 노드 인스턴스 타입 설정
#
#   ami_type        = "AL2_x86_64"  # ✅ Amazon Linux 2 기반 AMI 사용
#   capacity_type  = "ON_DEMAND"         # 💡 비용 절감을 위해 Spot 인스턴스 사용
#
#   scaling_config {
#     desired_size = 2  # 💡 기본 2개 노드
#     min_size     = 1
#     max_size     = 5
#   }
#
#   update_config {
#     max_unavailable = 1
#   }
#
#   depends_on = [
#     aws_eks_cluster.eks,
#     aws_iam_role_policy_attachment.eks_worker_node_policy
#   ]
# }
#
# resource "aws_iam_role" "eks_cluster_role" {
#   name = "eks-cluster-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "eks.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }
#
# resource "aws_iam_role" "eks_admin_role" {
#   name = "eks-admin-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         AWS = "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:root"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "eks_admin_policy" {
# role       = aws_iam_role.eks_admin_role.name
# policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }
#
# resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
#   role       = aws_iam_role.eks_cluster_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }
#
# resource "aws_iam_role_policy_attachment" "eks_vpc_controller_policy" {
#   role       = aws_iam_role.eks_cluster_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
# }
# module "eks_aws_auth" {
#   source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
#   version = "~> 20.0"
#
#   manage_aws_auth_configmap = true
#
#   aws_auth_roles = [
#     {
#       rolearn  = "arn:aws:iam::034362047320:role/eks-cluster-eks-node-role"
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups   = ["system:bootstrappers", "system:nodes"]
#     }
#   ]
# }
#
# # EKS Node Group IAM 역할 생성
# resource "aws_iam_role" "eks_node_role" {
#   name = "${var.cluster_name}-eks-node-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "ec2.amazonaws.com" }
#     }]
#   })
# }
#
#
# # ✅ EKS Node Group IAM 역할에 정책 연결
# resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_node_role.name
# }
#
# resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_node_role.name
# }
#
# resource "aws_iam_role_policy_attachment" "eks_ec2_container_registry" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_node_role.name
# }
#
# # ✅ EKS 노드가 클러스터와 통신할 수 있도록 추가 정책 적용
# resource "aws_iam_role_policy_attachment" "eks_ssm_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   role       = aws_iam_role.eks_node_role.name
# }
