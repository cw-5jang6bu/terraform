variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = list(string)
}

variable "private_subnet_eks" {
  description = "EKS를 위한 Private Subnet CIDR 리스트"
  type        = list(string)
}

variable "private_subnet_db" {
  description = "RDS 및 ElastiCache를 위한 Private Subnet CIDR 리스트"
  type        = list(string)
}

variable "availability_zones" {
  description = "배포할 가용 영역 리스트"
  type        = list(string)
}
# variable "eks_cluster_name" {
#   description = "EKS Cluster Name"
#   type        = string
# }

