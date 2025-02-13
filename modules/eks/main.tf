resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name  = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn = aws_iam_role.eks_node_role.arn
  subnet_ids    = var.subnet_ids

  instance_types = [var.node_type]
  scaling_config {
    desired_size = var.node_count
    min_size     = 1
    max_size     = 5
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy
  ]
}

module "argocd" {
  source       = "./argocd"
  cluster_name = aws_eks_cluster.eks.name
  depends_on   = [aws_eks_cluster.eks]
}
