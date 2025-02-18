variable "private_subnet_ids" {
  description = "각 AZ별 private_subnet"
}

variable "lamda_sg_id" {
  description = "lamda security group id"
}

variable "cache_endpoint" {
  description = "cache_subnet endpoint"
}