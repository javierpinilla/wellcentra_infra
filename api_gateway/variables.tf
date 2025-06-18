variable "region" {
  description = "Región de AWS"
  type        = string
}

variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "common_tags" {
  description = "Etiquetas comunes para recursos"
  type        = map(string)
}

variable "environment" {
  description = "Entorno"
  type        = string
}