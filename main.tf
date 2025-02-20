# ✅ VPC 모듈 (서브넷, NAT, 보안 그룹 포함)
module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.11.0/24"]  # ✅ Bastion 용 Public Subnet
  private_subnet_eks  = ["10.0.2.0/24", "10.0.21.0/24"]  # ✅ EKS 용 Private Subnet
  private_subnet_db   = ["10.0.3.0/24", "10.0.31.0/24"]  # ✅ RDS & ElastiCache 용
  availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
 # ✅ VPC 생성 후 실행
}

module "rds" {
  source                     = "./modules/rds"
  db_name                    = "test"
  db_password                = "11111111"
  db_username                = "admin"
  private_subnet_db_ids      = module.vpc.private_subnet_db
  vpc_id                     = module.vpc.vpc_id
  rds_sg_id                  = module.vpc.rds_sg_id

  depends_on = [module.vpc]
}

module "elasticache" {
  source                        = "./modules/elasticache"
  vpc_id                        = module.vpc.vpc_id
  private_subnet_eks_ids        = module.vpc.private_subnet_eks
  elasticache_sg_id             = module.vpc.eks_sg_id

  depends_on = [module.vpc]
}


# # ✅ EKS 모듈
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "eks-cluster"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_eks
  eks_sg_id          = module.vpc.eks_sg_id
  ssh_key_name       = "dev-keypair"

  depends_on = [module.vpc]
}

# ✅ LAMBDA 모듈
# module "lambda" {
#   source             = "./modules/lambda"
#   private_subnet_ids = [module.vpc.private_subnet_eks]
#   lambda_sg_id        = module.vpc.lambda_sg_id
#   cache_endpoint     = module.elasticache.redis_primary_endpoint
# }
