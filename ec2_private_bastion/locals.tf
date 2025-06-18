locals {
  vpc_name = "${var.vpc_name}-${var.environment}"
  ec2_name = "${var.vpc_name}-private-bastion-${var.environment}"
}