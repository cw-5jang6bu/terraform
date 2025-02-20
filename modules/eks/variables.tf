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
