variable "ami_id" {}
variable "instance_type" {}
variable "private_subnet_id" {}
variable "private_ip" {}
variable "vpc_id" {}
variable "bastion_sg_id" {}  # Bastion Host의 Security Group ID
variable "key_pair" {}       # SSH 접속을 위한 키 파일
variable "vpc_name" {}