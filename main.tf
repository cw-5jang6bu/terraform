provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "olive-young-vpc"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "ap-northeast-2a"
}

module "bastion" {
  source           = "./modules/bastion"
  vpc_id           = module.vpc.vpc_id
  vpc_name         = "olive-young-vpc"
  public_subnet_id = module.vpc.public_subnet_id
  ami_id           = "ami-037f2fa59e7cfbbbb"
  instance_type    = "t2.micro"
  key_pair         = "dev-keypair"
}

module "private-ec2" {
  source           = "./modules/private-ec2"
  vpc_name         = "olive-young-vpc"
  private_subnet_id = module.vpc.private_subnet_id
  ami_id           = "ami-0cee4e6a7532bb297"
  instance_type    = "t2.micro"
  private_ip       = "10.0.2.10"
  vpc_id           = module.vpc.vpc_id
  bastion_sg_id    = module.bastion.bastion_sg_id  # Bastion SG 전달
  key_pair         = "dev-keypair"
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  node_count   = var.node_count
  node_type    = var.node_type
  subnet_ids   = var.subnet_ids
  vpc_id       = var.vpc_id
  nat_gateway  = var.nat_gateway
}

module "argocd" {
  source            = "./modules/eks/argocd"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca_cert   = module.eks.cluster_ca_cert
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_cert)
  }
}