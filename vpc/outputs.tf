output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "rds_subnet_ids" {
  value = aws_subnet.subnet_private_rds[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.subnet_private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.subnet_public[*].id
}

output "sg_rds" {
  value = aws_security_group.vpc_rds_sg.id
}