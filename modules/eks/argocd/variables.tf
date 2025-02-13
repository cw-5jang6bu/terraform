variable "cluster_name" {
  description = "EKS 클러스터 이름"
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
