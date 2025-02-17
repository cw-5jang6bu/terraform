provider "aws" {
  region = var.aws_region
}

# module "s3_bucket" {
#   source       = "./modules/s3"
#   bucket_name  = "ojang-terraform-state"
#   acl          = "private"
#   versioning   = true
# }

# VPC 모듈 (서브넷, NAT, 보안 그룹 포함)
module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.11.0/24"]  # Bastion 용 Public Subnet
  private_subnet_eks  = ["10.0.2.0/24", "10.0.21.0/24"]  # EKS 용 Private Subnet
  private_subnet_db   = ["10.0.3.0/24", "10.0.31.0/24"]  # RDS & ElastiCache 용
  availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
}

#EKS 모듈 (EKS 클러스터 + Node Group)
# module "eks" {
#   source             = "./modules/eks"
#   cluster_name       = "eks-cluster"
#   subnet_ids         = module.vpc.private_subnet_eks
#   security_group_id  = module.vpc.eks_sg_id
#   eks_node_sg_id     = module.vpc.eks_node_sg_id
#   depends_on         = [module.vpc]  # ✅ VPC 생성 후 EKS 실행
# }
#
# RDS 모듈 (Aurora Serverless v2)
module "rds" {
  source             = "./modules/rds"
  db_name            = "oliveyoungdb"
  master_username    = "admin"
  master_password    = "11111111"
  rds_subnet_ids     = [module.vpc.private_subnet_db[0], module.vpc.private_subnet_db[1]] # ✅ 2개만 선택
  security_group_ids = [module.vpc.db_sg_id]
  depends_on         = [module.vpc]
}

#
# ElastiCache 모듈 (Redis Cluster)
module "elasticache" {
  source             = "./modules/elasticache"
  cache_cluster_id   = "redis-cluster"
  subnet_ids         = module.vpc.private_subnet_db
  security_group_ids = module.vpc.cache_sg_id # ✅ 리스트로 변환
  depends_on         = [module.vpc]  # ✅ VPC 생성 후 실행
}


