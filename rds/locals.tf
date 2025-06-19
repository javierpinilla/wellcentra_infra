locals {
  vpc_name              = "${var.vpc_name}-${var.environment}"
  rds_subnet_group_name = "rds-subnetgroup-prv-${local.vpc_name}"
  rds_name              = "${var.vpc_name}-${var.environment}"
  db_name               = var.vpc_name
}