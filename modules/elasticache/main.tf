# 1️⃣ ElastiCache Subnet Group 생성 (EKS와 동일한 Private Subnet 사용)
resource "aws_elasticache_subnet_group" "elasticache" {
  name       = "elasticache-subnet-group"
  subnet_ids = var.private_subnet_eks_ids # ✅ EKS와 동일한 Subnet 사용

  tags = {
    Name = "elasticache-subnet-group"
  }
}

# 2️⃣ ElastiCache Redis Cluster (최적화된 배포)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "redis-cluster-fast"
  description                   = "Optimized Redis Cluster with Single Node First"
  engine                        = "redis"
  engine_version                = "7.0"
  node_type                     = "cache.t4g.small" # ✅ 초기 배포 속도 최적화
  num_node_groups               = 1  # ✅ 클러스터 모드 비활성화 (단일 샤드)
  replicas_per_node_group       = 0  # ✅ Primary만 생성 (후에 Replica 추가)
  automatic_failover_enabled    = false # ✅ 초기 배포 속도 개선 (이후 활성화 가능)
  multi_az_enabled              = false # ✅ 초기 배포 속도 개선 (이후 활성화 가능)
  subnet_group_name             = aws_elasticache_subnet_group.elasticache.name
  security_group_ids            = [var.elasticache_sg_id]

  tags = {
    Name = "elasticache-redis-cluster-fast"
  }
}

