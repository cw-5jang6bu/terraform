variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "subnet_ids" {
  description = "EKS 클러스터가 사용할 서브넷 목록 (Private Subnet)"
  type        = list(string)
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "eks_sg_id" {
  description = "eks security group id"
  type        = string
}

variable "ssh_key_name" {
  description = "ssh key name"
  type        = string
}

# variable "elasticache_sg_id" {
#   description = "elasticache sg"
#   type        = string
# }
#
# variable "rds_sg_id" {
#   description = "rds sg"
#   type        = string
# }

# variable "eks_node_sg_id" {
#   description = "EKS 노드 그룹에 사용할 보안 그룹 ID"
#   type        = string
# }

# variable "aws_region" {
#   description = "AWS Region"
#   type        = string
# }
