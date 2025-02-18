# ElastiCache Subnet Group 생성
resource "aws_elasticache_subnet_group" "cache" {
  name       = "cache-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "elasticache-subnet-group"
  }
}

resource "aws_elasticache_parameter_group" "redis_cluster" {
  name   = "redis-cluster-param-group"
  family = "redis6.x"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id      = "redis-cluster"
  description               = "Redis Replication Group for High Availability"
  engine                    = "redis"
  engine_version            = "6.x"
  node_type                 = "cache.t4g.micro"
  parameter_group_name      = aws_elasticache_parameter_group.redis_cluster.name  # ✅ 클러스터 활성화된 파라미터 그룹 사용
  port                      = 6379
  num_node_groups           = 2  # ✅ 2개 이상의 노드 그룹 사용 가능
  replicas_per_node_group   = 1
  automatic_failover_enabled = true
  multi_az_enabled          = true
  security_group_ids = [
    aws_security_group.redis_sg.id,
    aws_security_group.lambda_sg.id,  
  ]
  subnet_group_name         = aws_elasticache_subnet_group.cache.name
}

