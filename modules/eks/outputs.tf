output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = aws_eks_cluster.eks.id
}

output "cluster_name" {
  description = "EKS 클러스터 이름"
  value       = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  description = "EKS 클러스터 엔드포인트"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_ca_cert" {
  description = "EKS 클러스터 CA 인증서"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "node_group_arn" {
  description = "EKS 노드 그룹 ARN"
  value       = aws_eks_node_group.eks_nodes.arn
}

