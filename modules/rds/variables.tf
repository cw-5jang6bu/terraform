variable "db_name" {
  description = "db name"
}

variable "db_username" {
  description = "db username"
}

variable "db_password" {
  description = "db password"
}

variable "private_subnet_db_ids" {
  description = "private subnet db ids"
}

variable "vpc_id" {
  description = "Id of vpc for db instance"
}

variable "rds_sg_id" {
  description = "rds sg id"
}

# variable "vpc_security_group_ids_rds" {
#   description = "ID for security group for rds"
# }

# variable "elasticache_sg_id" {
#   description = "elasticache sg ids"
# }
#
# variable "eks_sg_id" {
#   description = "eks sg id"
# }





