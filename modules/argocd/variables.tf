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

variable "cluster_id" {
  description = "EKS 클러스터 ID"
  type = string
}

variable "helm_release_enabled" {
  description = "EKS가 배포 완료된 후 Helm 차트를 실행할지 여부"
  type        = bool
  default     = false
}

