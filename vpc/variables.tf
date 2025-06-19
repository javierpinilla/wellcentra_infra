variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_cidr_all" {
  type        = string
  description = "CIDR Block for all traffic (0.0.0.0/0)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR Block for VPC"
}

variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "subnet_public_cidrs" {
  description = "CIDR blocks para subredes públicas"
  type        = list(string)
}

variable "subnet_private_cidrs" {
  description = "CIDR blocks para subredes privadas generales"
  type        = list(string)
}

variable "subnet_private_rds_cidrs" {
  description = "CIDR blocks para subredes privadas de RDS"
  type        = list(string)
}

variable "common_tags" {
  description = "Etiquetas comunes para todos los recursos"
  type        = map(string)
}

variable "environment" {
  description = "Entorno"
  type        = string
}