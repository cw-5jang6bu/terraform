output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Ids of Public Subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_eks" {
  description = "EKS용 Private Subnet 리스트"
  value       = aws_subnet.private_eks[*].id
}

output "private_subnet_db" {
  description = "RDS & ElastiCache용 Private Subnet 리스트"
  value       = aws_subnet.private_db[*].id
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

output "elasticache_sg_id" {
  description = "elasticache Security Group ID"
  value       = aws_security_group.elasticache_sg.id
}

output "eks_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.eks_sg.id
}

output "rds_subnet_ids" {
  description = "RDS용 subnet의 ids"
  value = aws_subnet.private_db[*].id
}
