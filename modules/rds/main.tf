# 1️⃣ Aurora MySQL Subnet Group 생성 (Private DB Subnet에 배포)
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = var.private_subnet_db_ids # ✅ private_subnet_db 사용

  tags = {
    Name = "aurora-subnet-group"
  }
}


resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-mysql-cluster"
  engine                 = "aurora-mysql"
  engine_version         = "8.0.mysql_aurora.3.04.0"
  database_name          = var.db_name
  master_username        = var.db_username
  master_password        = var.db_password
  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  skip_final_snapshot = true
  storage_encrypted      = true
  backup_retention_period = 7
  deletion_protection    = false
  apply_immediately      = true

  # ✅ Serverless v2 스케일링 설정 (최소/최대 ACU 설정)
  serverlessv2_scaling_configuration {
    min_capacity = 0.5  # ✅ 최소 0.5 ACU
    max_capacity = 4    # ✅ 최대 4 ACU (트래픽 증가 시 자동 확장)
  }
}

# # 3️⃣ Aurora 인스턴스 생성 (1개는 Primary, 1개는 Replica)
# resource "aws_rds_cluster_instance" "aurora_instances" {
#   count                 = 2  # ✅ 첫 번째는 Primary, 두 번째는 Replica
#   identifier            = "aurora-mysql-${count.index}"
#   cluster_identifier    = aws_rds_cluster.aurora.id
#   instance_class        = "db.t3.medium"  # ✅ `db.t3.micro`는 Aurora 미지원 → 최소 `t3.medium` 사용
#   engine               = aws_rds_cluster.aurora.engine
#   engine_version       = aws_rds_cluster.aurora.engine_version
#   publicly_accessible  = false
#   db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
# } => 인스턴스를 활용할 때


# # RDS 보안 그룹
# resource "aws_security_group" "rds_sg" {
#   vpc_id      = var.vpc_id
#   name        = "rds-security-group"
#   description = "Security group for RDS"
#
#   # ✅ EKS → RDS (MySQL, 3306)
#   ingress {
#     from_port       = 3306
#     to_port         = 3306
#     protocol        = "tcp"
#     security_groups = [var.eks_sg_id]
#     description     = "Allow MySQL access from EKS"
#   }
#
#   # # ✅ RDS → ElastiCache (Redis, 6379) 직접 접근 가능 (캐싱 활용)
#   # ingress {
#   #   from_port       = 6379
#   #   to_port         = 6379
#   #   protocol        = "tcp"
#   #   security_groups = [var.elasticache_sg_id]
#   #   description     = "Allow Redis access from RDS"
#   # }
#
#   # ✅ RDS에서 Redis(ElastiCache) 접근 가능하도록 설정
#   egress {
#     from_port       = 6379
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [var.elasticache_sg_id]
#     description     = "Allow outbound Redis traffic to ElastiCache"
#   }
#
#   tags = {
#     Name = "rds-sg"
#   }
# }

# resource "aws_security_group_rule" "rds_to_redis_ingress" {
#   type                     = "ingress"
#   from_port                = 6379
#   to_port                  = 6379
#   protocol                 = "tcp"
#   security_group_id        = var.elasticache_sg_id # Redis 보안 그룹
#   source_security_group_id = aws_security_group.rds_sg.id # RDS 보안 그룹
# }
#
# resource "aws_security_group_rule" "" {
#   from_port         = 3306
#   protocol          = "tcp"
#   security_group_id = [var.eks_sg_id]
#   to_port           = 3306
#   type              = "ingress"
# }



