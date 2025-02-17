variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "subnet_ids" {
  description = "EKS가 배포될 Private Subnet 리스트"
  type        = list(string)
}

variable "security_group_id" {
  description = "EKS에 적용할 보안 그룹 ID"
  type        = string
}

variable "ssh_key_name" {
  description = "EC2 SSH Key Name for EKS nodes"
  type        = string
  default     = "dev-keypair"
}

variable "eks_node_sg_id" {
  description = "EKS Node Security group Id"
  type        = string
}
