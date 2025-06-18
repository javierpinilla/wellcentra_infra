output "rds_endpoint" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "Endpoint rds"
}

output "rds_secret_arn" {
  value       = aws_secretsmanager_secret.rds_secret.arn
  description = "ARN Secret Rds"
}

output "rds_app_secret_arn" {
  value       = aws_secretsmanager_secret.rds_app_secret.arn
  description = "ARN App Secret Rds"
}