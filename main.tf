# ✅ VPC 모듈 (서브넷, NAT, 보안 그룹 포함)
module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.11.0/24"]  # ✅ Bastion 용 Public Subnet
  private_subnet_eks  = ["10.0.2.0/24", "10.0.21.0/24"]  # ✅ EKS 용 Private Subnet
  private_subnet_db   = ["10.0.3.0/24", "10.0.31.0/24"]  # ✅ RDS & ElastiCache 용
  availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
  eks_cluster_name    = module.eks.cluster_name
}

# ✅ EKS 모듈 (EKS 클러스터 + Node Group)
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "eks-cluster"  # ✅ VPC 모듈에서 받지 않음 (순환 참조 방지)
  subnet_ids         = module.vpc.private_subnet_eks
  security_group_id  = module.vpc.eks_sg_id
  eks_node_sg_id     = module.vpc.eks_node_sg_id
  depends_on         = [module.vpc]  # ✅ VPC 생성 후 EKS 실행
  aws_region         = var.aws_region
}

# ✅ RDS 모듈 (Aurora Serverless v2)
module "rds" {
  source             = "./modules/rds"
  db_name            = "oliveyoungdb"
  master_username    = "admin"
  master_password    = "11111111"
  rds_subnet_ids     = module.vpc.private_subnet_db  # ✅ 올바르게 전체 전달
  security_group_ids = [module.vpc.db_sg_id]
  depends_on         = [module.vpc]
}

# ✅ ElastiCache 모듈 (Redis Cluster)
module "elasticache" {
  source             = "./modules/elasticache"
  cache_cluster_id   = "redis-cluster"
  subnet_ids         = module.vpc.private_subnet_eks # 원래 구성도 같이 eks 서브넷에 붙이기
  security_group_ids = module.vpc.cache_sg_id  # ✅ 리스트로 변환
  depends_on         = [module.vpc]
}

module "alb" {
  source           = "./modules/alb"
  alb_name         = "eks-alb"
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.ublic_subnet_idsp
  alb_security_group = module.vpc.alb_sg_id
}


# ✅ ArgoCD 배포 (Helm 사용)
module "argocd" {
  source            = "./modules/argocd"
  cluster_id        = module.eks.cluster_id
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca_cert   = module.eks.cluster_ca_cert
  depends_on        = [module.eks]
}


# provider "aws" {
#   region = var.aws_region
# }
#
# # VPC 모듈 (서브넷, NAT, 보안 그룹 포함)
# module "vpc" {
#   source              = "./modules/vpc"
#   vpc_cidr            = "10.0.0.0/16"
#   public_subnet_cidr  = ["10.0.1.0/24", "10.0.11.0/24"]  # Bastion 용 Public Subnet
#   private_subnet_eks  = ["10.0.2.0/24", "10.0.21.0/24"]  # EKS 용 Private Subnet
#   private_subnet_db   = ["10.0.3.0/24", "10.0.31.0/24"]  # RDS & ElastiCache 용
#   availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
#   cluster_name        = module.eks.cluster_name
# }
#
# # EKS 모듈 (EKS 클러스터 + Node Group)
# module "eks" {
#   source             = "./modules/eks"
#   cluster_name       = "eks-cluster"
#   subnet_ids         = module.vpc.private_subnet_eks
#   security_group_id  = module.vpc.eks_sg_id
#   eks_node_sg_id     = module.vpc.eks_node_sg_id
#   depends_on         = [module.vpc]  # ✅ VPC 생성 후 EKS 실행
# }
#
# # RDS 모듈 (Aurora Serverless v2)
# module "rds" {
#   source             = "./modules/rds"
#   db_name            = "oliveyoungdb"
#   master_username    = "admin"
#   master_password    = "11111111"
#   rds_subnet_ids     = [module.vpc.private_subnet_db[0], module.vpc.private_subnet_db[1]] # ✅ 2개만 선택
#   security_group_ids = [module.vpc.db_sg_id]
#   depends_on         = [module.vpc]
# }
#
# #
# # ElastiCache 모듈 (Redis Cluster)
# module "elasticache" {
#   source             = "./modules/elasticache"
#   cache_cluster_id   = "redis-cluster"
#   subnet_ids         = module.vpc.private_subnet_db
#   security_group_ids = module.vpc.cache_sg_id # ✅ 리스트로 변환
#   depends_on         = [module.vpc]  # ✅ VPC 생성 후 실행
# }
#
# # ✅ ArgoCD 배포 (Helm 사용)
# module "argocd" {
#   source            = "./modules/argocd"
#   cluster_id        = module.eks.cluster_id
#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   cluster_ca_cert   = module.eks.cluster_ca_cert
#   depends_on        = [module.eks]
# }

######## 수정 버전 일단 건들 X
# provider "aws" {
#   region = var.aws_region
# }
#
# # ✅ VPC 모듈 (서브넷, NAT, 보안 그룹 포함)
# module "vpc" {
#   source              = "./modules/vpc"
#   vpc_cidr            = "10.0.0.0/16"
#   public_subnet_cidr  = ["10.0.1.0/24", "10.0.11.0/24"]  # Bastion 용 Public Subnet
#   private_subnet_eks  = ["10.0.2.0/24", "10.0.21.0/24"]  # EKS 용 Private Subnet
#   private_subnet_db   = ["10.0.3.0/24", "10.0.31.0/24"]  # RDS & ElastiCache 용
#   availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
# }
#
# # ✅ EKS 모듈 (EKS 클러스터 + Node Group)
# module "eks" {
#   source             = "./modules/eks"
#   cluster_name       = "eks-cluster"
#   subnet_ids         = module.vpc.private_subnet_eks
#   security_group_id  = module.vpc.eks_sg_id
#   eks_node_sg_id     = module.vpc.eks_node_sg_id
#   depends_on         = [module.vpc]  # ✅ VPC 생성 후 EKS 실행
# }
#
# # ✅ RDS 모듈 (Aurora Serverless v2)
# module "rds" {
#   source             = "./modules/rds"
#   db_name            = "oliveyoungdb"
#   master_username    = "admin"
#   master_password    = "11111111"
#   rds_subnet_ids     = [module.vpc.private_subnet_db[0], module.vpc.private_subnet_db[1]] # ✅ 2개만 선택
#   security_group_ids = [module.vpc.db_sg_id]  # ✅ 리스트 형태로 변환
#   depends_on         = [module.vpc]
# }
#
# # ✅ ElastiCache 모듈 (Redis Cluster)
# module "elasticache" {
#   source             = "./modules/elasticache"
#   cache_cluster_id   = "redis-cluster"
#   subnet_ids         = module.vpc.private_subnet_db
#   security_group_ids = [module.vpc.cache_sg_id]  # ✅ 리스트 형태로 변환
#   depends_on         = [module.vpc]  # ✅ VPC 생성 후 실행
# }
