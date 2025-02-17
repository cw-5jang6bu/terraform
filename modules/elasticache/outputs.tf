output "redis_primary_endpoint" {
  description = "ElastiCache Redis Primary Endpoint"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_cluster_id" {
  description = "ElastiCache 클러스터 ID"
  value       = aws_elasticache_replication_group.redis.id
}
