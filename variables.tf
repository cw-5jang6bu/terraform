variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
  default = "eks-prod-test-cluster-v1"
}

variable "node_count" {
  description = "EKS 노드 개수"
  type        = number
  default     = 2
}

variable "node_type" {
  description = "EKS 노드 유형"
  type        = string
  default     = "t3.large"
}

variable "subnet_ids" {
  description = "EKS 서브넷 ID 목록"
  type        = list(string)
}

variable "vpc_id" {
  description = "EKS가 연결될 VPC ID"
  type        = string
}

variable "nat_gateway" {
  description = "NAT 게이트웨이 ID"
  type        = string
}
