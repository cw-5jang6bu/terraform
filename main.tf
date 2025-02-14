provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_cert)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--region", var.aws_region, "--cluster-name", module.eks.cluster_name]
    } # IAM 인증 추가
  }
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "olive-young-vpc"
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.11.0/24"]  # AZ별 퍼블릭 서브넷 CIDR
  private_subnet_cidr = ["10.0.3.0/24", "10.0.13.0/24"]  # AZ별 프라이빗 서브넷 CIDR
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]  # 2개 AZ 사용
}

module "bastion" {
  source           = "./modules/bastion"
  vpc_id           = module.vpc.vpc_id
  vpc_name         = "olive-young-vpc"
  public_subnet_id = module.vpc.public_subnet_ids[0]
  ami_id           = "ami-037f2fa59e7cfbbbb"
  instance_type    = "t2.micro"
  key_pair         = "dev-keypair"
}

module "private-ec2" {
  source           = "./modules/private-ec2"
  vpc_name         = "olive-young-vpc"
  private_subnet_id = module.vpc.private_subnet_ids[0]
  ami_id           = "ami-0cee4e6a7532bb297"
  instance_type    = "t2.micro"
  private_ip       = "10.0.3.10"
  vpc_id           = module.vpc.vpc_id
  bastion_sg_id    = module.bastion.bastion_sg_id  # Bastion SG 전달
  key_pair         = "dev-keypair"
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  node_count   = var.node_count
  node_type    = var.node_type
  subnet_ids   = module.vpc.private_subnet_ids
  vpc_id       = module.vpc.vpc_id
  nat_gateway  = module.vpc.nat_gateway_id
}

module "argocd" {
  source            = "./modules/argocd"
  cluster_id = module.eks.cluster_id
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca_cert   = module.eks.cluster_ca_cert
  depends_on = [module.eks]  # ✅ EKS가 올라간 후 실행
}
