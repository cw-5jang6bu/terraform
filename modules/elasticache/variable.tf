variable "cache_cluster_id" {
  description = "ElastiCache Redis 클러스터 ID"
  type        = string
}

variable "subnet_ids" {
  description = "ElastiCache가 배포될 Private Subnet 리스트"
  type        = list(string)
}

variable "security_group_ids" {
  description = "ElastiCache에 적용할 보안 그룹 ID 리스트"
  type        = list(string)  # 반드시 리스트 형태여야 함
}

