variable "alb_name" {
  description = "ALB 이름"
  type        = string
}

variable "vpc_id" {
  description = "ALB가 속할 VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "ALB가 배포될 Public Subnet ID 리스트"
  type        = list(string)
}

variable "alb_security_group" {
  description = "ALB 보안 그룹 ID"
  type        = string
}
