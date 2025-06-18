locals {
  vpc_name = "${var.vpc_name}-${var.environment}"
  lambda_name = "${var.vpc_name}-api-be-${var.environment}"
  rds_name = "${var.vpc_name}-${var.environment}"
  secret_name = "app/${var.environment}/${var.vpc_name}"
}