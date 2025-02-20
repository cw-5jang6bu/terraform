resource "aws_eks_cluster" "eks" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.eks_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = true # ✅ 내부에서만 접근 가능
    public_access_cidrs = ["0.0.0.0/0"] # test -> 실제로는 내 IP만 적어서 보안성 향상
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
