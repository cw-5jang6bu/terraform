# output "redis_primary_endpoint" {
#   value = aws_elasticache_replication_group.redis.primary_endpoint_address
# }
#
# output "redis_cluster_id" {
#   description = "ElastiCache 클러스터 ID"
#   value       = aws_elasticache_replication_group.redis.id
# }

# output "elasticache_sg_id" {
#   description = "The security group id of the elasticache cluster"
#   value       = aws_security_group.elasticache_sg.id
# }