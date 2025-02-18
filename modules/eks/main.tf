# EKS 클러스터 생성
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids  # ✅ VPC 모듈에서 전달된 Private Subnet 사용
    security_group_ids      = [var.security_group_id]  # ✅ VPC에서 전달된 보안 그룹 사용    endpoint_private_access = true  # ✅ 내부 통신 허용 (kubectl 등 내부 접근 가능)
    endpoint_private_access = true # ✅ 내부 접근 가능하도록 설정
    endpoint_public_access  = true  # ✅ 외부 접근 가능 (ArgoCD CLI 필요)
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# EKS Node Group 생성
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids  # ✅ Private Subnet 사용
  instance_types = ["t3.medium"]  # ✅ 노드 인스턴스 타입 설정

  ami_type        = "AL2_x86_64"  # ✅ Amazon Linux 2 기반 AMI 사용
  capacity_type  = "SPOT"         # 💡 비용 절감을 위해 Spot 인스턴스 사용

  scaling_config {
    desired_size = 2  # 💡 기본 2개 노드
    min_size     = 1
    max_size     = 5
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.eks_worker_node_policy
  ]
}

# EKS 클러스터용 IAM 역할 생성
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# EKS 클러스터 IAM 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Node Group IAM 역할 생성
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}


# ✅ EKS Node Group IAM 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ec2_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# ✅ EKS 노드가 클러스터와 통신할 수 있도록 추가 정책 적용
resource "aws_iam_role_policy_attachment" "eks_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node_role.name
}




