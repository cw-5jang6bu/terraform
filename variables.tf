variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]  # 원하는 AZ 추가
}


variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
  default     = "eks-prod-test-cluster-v1"
}

variable "node_count" {
  description = "EKS 노드 개수"
  type        = number
  default     = 2
}

variable "node_type" {
  description = "EKS 노드 유형"
  type        = string
  default     = "t3.medium"
}

variable "subnet_ids" {
  description = "EKS 서브넷 ID 목록"
  type        = string
}

variable "vpc_id" {
  description = "EKS가 연결될 VPC ID"
  type        = string
}

variable "nat_gateway" {
  description = "NAT 게이트웨이 ID"
  type        = string
}

# ✅ ArgoCD 관련 변수 추가
variable "cluster_id" {
  description = "EKS 클러스터 ID"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS API 서버 엔드포인트"
  type        = string
}

variable "cluster_ca_cert" {
  description = "EKS 클러스터 CA 인증서"
  type        = string
}
