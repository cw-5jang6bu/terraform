variable "db_name" {
  description = "RDS 데이터베이스 이름"
  type        = string
}

variable "security_group_ids" {
  description = "RDS에 적용할 보안 그룹 ID"
  type        = list(string)
}

variable "master_username" {
  description = "RDS에 적용할 username"
  type        = string
}

variable "master_password" {
  description = "RDS에 적용할 password"
  type        = string
}

variable "rds_subnet_ids" {
  description = "RDS용 private_subnet_ids"
  type        = list(string)
}

