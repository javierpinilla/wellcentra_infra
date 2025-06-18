# Proyecto: RDS + EC2 con Secret Manager

Este proyecto despliega:

- **RDS PostgreSQL** en subred privada con cifrado y secret manager
- **EC2 Ubuntu** en subred privada con SSM Agent y sin SSH keys

## Requisitos

- Terraform v1.0+
- AWS CLI configurado
- Correr el terraform de la VPC.

## Variables Requeridas

| Variable                 | Descripción                              |
|--------------------------|------------------------------------------|
| `region`                 | Región de AWS                            |
| `vpc_name`               | Nombre de la VPC existente               |
| `rds_subnet_group_name`  | Nombre del grupo de subredes de RDS      |
| `ami_id`                 | ID del AMI de Ubuntu 24.04               |
| `common_tags`            | Etiquetas comunes para todos los recursos|


## Ejemplo de `terraform.tfvars`

```hcl
region = "us-east-2"
vpc_name = "vpc-example-name"
rds_subnet_group_name = "rds-subnetgroup-vpc-example-name"
ami_id = "ami-0d1b5a8c13042c939" # Ubuntu 24.04
common_tags = {
  Project     = "Poject_name"
  Environment = "Environment_name"
  Owner       = "Owner_name"
}
```


## Configurar donde se va a guardar el `terraform.tfstate` en el archivo `backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "bucket_name_tf_state"
    key            = "terraform/poject_name/rds_ec2/state"
    region         = "us-east-1"
    encrypt        = true
  }

  # Y si queremos el tfstate local.
  #backend "local" {
  #  path = "terraform.tfstate"
  #}
}
```

## Nota Importante
### Este proyecto usa un Rds tipo db.t4g.micro que es mas barato que t3.micro:
`db.t4g.micro $0.0160 hourly`\
`db.t3.micro  $0.0180 hourly`



## [Aquí puedes Comparar costos de recursos de `AWS`](https://instances.vantage.sh/)



## Rotación de secretos para rds

Si necesitas rotar el secreto del rds, deberás usar una función lambda. Y Aws tiene plantillas de código para esto.\
Puedes consultar la siguiente [docu](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html)