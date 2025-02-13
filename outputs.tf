output "cluster_id" {
  description = "EKS 클러스터 ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS API 서버 엔드포인트"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_cert" {
  description = "EKS 클러스터 CA 인증서"
  value       = module.eks.cluster_ca_cert
}
