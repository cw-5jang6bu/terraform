# RDS Subnet Group 생성 (각 AZ에서 하나의 Private Subnet만 선택)
resource "aws_db_subnet_group" "db" {
  name       = "db-subnet-group"
  subnet_ids = [var.rds_subnet_ids[0], var.rds_subnet_ids[1]]# ✅ 첫 번째 AZ의 첫 번째 Subnet, 두 번째 AZ의 첫 번째 Subnet 선택

  tags = {
    Name = "rds-subnet-group"
  }
}


# RDS Aurora Serverless v2 Cluster 생성
resource "aws_rds_cluster" "aurora" {
  cluster_identifier   = var.db_name
  engine              = "aurora-mysql"
  engine_version      = "8.0.mysql_aurora.3.04.0"
  database_name       = var.db_name
  master_username     = var.master_username
  master_password     = var.master_password
  db_subnet_group_name = aws_db_subnet_group.db.name
  vpc_security_group_ids = var.security_group_ids  # ✅ 리스트 형태로 전달

  # Aurora Serverless v2 설정 (올바른 설정)
  serverlessv2_scaling_configuration {
    min_capacity = 2
    max_capacity = 8
  }

  storage_encrypted = true
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"

  # ✅ 스냅샷 없이 삭제하도록 설정
  skip_final_snapshot      = true

  depends_on = [aws_db_subnet_group.db]
}


