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

# # ElastiCache 보안 그룹
# resource "aws_security_group" "elasticache_sg" {
#   vpc_id = var.vpc_id
#   name   = "elasticache-sg"
#   description = "Security group for Elasticache"
#
#   # ✅ EKS → Redis (6379) 접근 허용
#   ingress {
#     from_port       = 6379
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [var.eks_sg_id]
#     description     = "Allow Redis access from EKS"
#   }
#
#   # ✅ RDS → Redis 접근 허용 (RDS에서 Redis를 캐싱 레이어로 사용 가능)
#   ingress {
#     from_port       = 6379
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [var.rds_sg_id]
#     description     = "Allow Redis access from RDS"
#   }
#
#   # # ✅ Outbound 트래픽 허용 (EKS, Lambda, RDS로 데이터 전송 가능)
#   # egress {
#   #   from_port   = 0
#   #   to_port     = 0
#   #   protocol    = "-1"
#   #   cidr_blocks = ["0.0.0.0/0"] # ✅ 필요한 경우 특정 CIDR 또는 보안 그룹 ID로 제한 가능
#   # }
#
#   # EKS 보안 그룹에서 들어오는 트래픽을 허용하는 rule을 따로 생성해야 함!
#   tags = {
#     Name = "elasticache-sg"
#   }
# }

# resource "aws_security_group_rule" "redis_to_rds_ingress" {
#   type                     = "ingress"
#   from_port                = 3306  # ✅ MySQL, PostgreSQL 포트
#   to_port                  = 3306
#   protocol                 = "tcp"
#   security_group_id        = var.rds_sg_id # RDS 보안 그룹
#   source_security_group_id = aws_security_group.elasticache_sg.id # Redis 보안 그룹
# }
#
# resource "aws_security_group_rule" "redis_to_rds_egress" {
#   type                     = "egress"
#   from_port                = 3306
#   to_port                  = 3306
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.elasticache_sg.id # Redis 보안 그룹
#   source_security_group_id = var.rds_sg_id # RDS 보안 그룹
# }





# resource "aws_elasticache_parameter_group" "redis_cluster" {
#   name   = "redis-cluster-param-group"
#   family = "redis6.x"
#
#   parameter {
#     name  = "cluster-enabled"
#     value = "yes"
#   }
# }
#
# resource "aws_elasticache_replication_group" "redis" {
#   replication_group_id      = "redis-cluster"
#   description               = "Redis Replication Group for High Availability"
#   engine                    = "redis"
#   engine_version            = "6.x"
#   node_type                 = "cache.t4g.micro"
#   parameter_group_name      = aws_elasticache_parameter_group.redis_cluster.name  # ✅ 클러스터 활성화된 파라미터 그룹 사용
#   port                      = 6379
#   num_node_groups           = 2  # ✅ 2개 이상의 노드 그룹 사용 가능
#   replicas_per_node_group   = 1
#   automatic_failover_enabled = true
#   multi_az_enabled          = true
#   security_group_ids        = var.security_group_ids
#   subnet_group_name         = aws_elasticache_subnet_group.cache.name
# }

