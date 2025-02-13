provider "aws" {
  region = var.aws_region
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