output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_eks" {
  description = "EKS용 Private Subnet 리스트"
  value       = aws_subnet.private_eks[*].id
}

output "private_subnet_db" {
  description = "RDS & ElastiCache용 Private Subnet 리스트"
  value       = aws_subnet.private_db[*].id
}

output "eks_sg_id" {
  description = "EKS 보안 그룹 ID"
  value       = aws_security_group.eks_sg.id
}

output "db_sg_id" {
  description = "RDS 보안 그룹 ID"
  value       = aws_security_group.db_sg.id
}

output "cache_sg_id" {
  description = "ElastiCache 보안 그룹 ID 리스트"
  value       = [aws_security_group.cache_sg.id]  # ✅ 리스트로 출력 보장
}

output "eks_node_sg_id" {
  description = "EKS Node Security Group Id"
  value       = aws_security_group.eks_node_sg.id
}
output "rds_subnet_ids" {
  description = "RDS용 subnet의 ids"
  value = aws_subnet.private_db[*].id
}

