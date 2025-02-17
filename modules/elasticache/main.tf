# ElastiCache Subnet Group 생성
resource "aws_elasticache_subnet_group" "cache" {
  name       = "cache-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "elasticache-subnet-group"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = var.cache_cluster_id
  description                   = "Redis Replication Group for High Availability"
  engine                        = "redis"
  engine_version                = "6.x"
  node_type                     = "cache.t4g.micro"
  parameter_group_name          = "default.redis6.x"
  port                          = 6379
  automatic_failover_enabled    = true
  multi_az_enabled              = true
  security_group_ids            = var.security_group_ids
  subnet_group_name             = aws_elasticache_subnet_group.cache.name
  num_node_groups         = 2  # ✅ Multi-AZ 구성 (샤드 개수)
  replicas_per_node_group = 1  # ✅ 각 샤드당 리플리카 개수

  depends_on = [aws_elasticache_subnet_group.cache]
}
