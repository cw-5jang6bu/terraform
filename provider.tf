provider "aws" {
  region = var.aws_region
}

# data "aws_eks_cluster" "default" {
#   name = module.eks.cluster_name
# }
#
# data "aws_eks_cluster_auth" "default" {
#   name = module.eks.cluster_name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.default.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.default.token
# }
