variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "security_group_id" {}
variable "certificate_arn" { type = string }