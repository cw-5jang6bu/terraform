output "rds_endpoint" {
  description = "RDS 엔드포인트"
  value       = aws_rds_cluster.aurora.endpoint
}

output "rds_cluster_id" {
  description = "RDS 클러스터 ID"
  value       = aws_rds_cluster.aurora.id
}