provider "aws" {
  region = var.aws_region
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = "eks-cluster"
  node_count   = 2
  node_type    = "t3.large"
  subnet_ids   = var.subnet_ids
  vpc_id       = var.vpc_id
  nat_gateway  = var.nat_gateway
}
