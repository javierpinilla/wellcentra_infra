# Infraestructura de VPC.

Este repositorio contiene el código Terraform para desplegar una VPC con 3 subnets públicas, 3 subnets privadas y 3 subnet privadas para RDS. También crea un Internet Gateway para la subnets públicas, un Nat Gateway para las subnet privadas. Las subnets para rds no tienen salida a Internet, pero pueden descomentar el código de la asociación del la rt al ngw.

### Arquitectura
La infraestructura implementada sigue una arquitectura de tres capas:

Subredes Públicas : Para recursos que requieren acceso directo a Internet (ej: servidores web).\
Subredes Privadas : Para recursos internos con salidad a internet.\
Subredes Privadas para RDS : Sin salida a internet.

#### Se incluyen:

1 VPC con CIDR configurable.\
3 subredes públicas , 3 privadas y 3 para RDS (una por Availability Zone).\
Internet Gateway para acceso externo.\
NAT Gateway para salida segura desde redes privadas.\
Route Tables asociadas a cada tipo de red.\
Network ACLs personalizadas para cada tipo de red.\
Security Group para RDS PostgreSQL.\
DHCP Options default que setea el nombre.

### Requisitos
Terraform v1.0 o superior.\
AWS CLI configurado con credenciales válidas.\
Acceso a una cuenta de AWS con permisos para crear recursos VPC.

### Uso

1. Inicializar el proyecto
```bash
terraform init
```

2. Planificar el despliegue
```bash
terraform plan
```

3. Aplicar cambios
```bash
terraform apply
```

4. Destruir infraestructura (opcional)
```bash
terraform destroy
```



## Estructura del Proyecto

`├── main.tf`               # Recursos principales (VPC, subnets, NACLs, etc.)\
`├── variables.tf`          # Declaración de variables.\
`├── terraform.tfvars`      # Valores de variables.\
`├── outputs.tf`            # Outputs de vpc_id, subnets y sg.\
`└── README.md`             # Documentación actual.


## Variables Principales

#### `variables.tf`

```bash
| Variable                  | Tipo         | Descripción                                      |
|---------------------------|--------------|--------------------------------------------------|
| region                    | string       | Región de AWS                                    |
| vpc_cidr_all              | string       | CIDR para todo tráfico (0.0.0.0/0)               |
| vpc_cidr                  | string       | CIDR de la VPC                                   |
| vpc_name                  | string       | Nombre de la VPC                                 |
| subnet_public_cidrs       | list(string) | CIDRs para subredes públicas                     |
| subnet_private_cidrs      | list(string) | CIDRs para subredes privadas generales           |
| subnet_private_rds_cidrs  | list(string) | CIDRs para subredes privadas de RDS              |
| rds_subnet_group_name     | string       | Nombre del grupo de subredes para RDS            |
| common_tags               | map(string)  | Etiquetas comunes para todos los recursos        |
```

## Ejemplo de `terraform.tfvars`

```bash
| Variable                  | Valor Ejemplo                            |
|---------------------------|------------------------------------------|
| regio                     | us-east-1                                |
| vpc_cidr_al               | 0.0.0.0/0                                |
| vpc_cidr                  | 10.20.0.0/16                             |
| vpc_name                  | vpc-name                                 |
| rds_subnet_group_name     | rds-subnetgroup-vpc-name                 |
| subnet_public_cidrs       | ["10.0.1.0/24", "10.0.2.0/24", ...]      |
| subnet_private_cidrs      | ["10.0.21.0/24", "10.0.22.0/24", ...]    |
| subnet_private_rds_cidrs  | ["10.0.41.0/24", "10.0.42.0/24", ...]    |
| common_tags               | { Project = "Poject_name", ... }         |
```

## Seguridad
### Network ACLs:
Subredes públicas permiten tráfico completo (ingreso/salida).\
Subredes privadas permiten tráfico interno y salida a Internet.\
Subredes de RDS solo permiten tráfico PostgreSQL (puerto 5432) desde subredes privadas.\
Security Group para RDS:\
Permite tráfico TCP en puerto 5432 desde subredes privadas.\
Salida abierta a todas las IPs.



## Configurar donde se va a guardar el `terraform.tfstate` en el archivo `backend.tf`

```hcl
terraform {
  backend "s3" {
    bucket         = "bucket_name_tf_state"
    key            = "terraform/poject_name/vpc/state"
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
### Este proyecto usa un Nat Gateway que tiene costo:
El costo de un NAT Gateway en AWS es de 0.045 USD por hora y 0.045 USD por GB de datos procesados. También hay un costo por la dirección IPv4 pública si se usa, que es de 0.005 USD por hora por dirección. Estos son valores aproximados.




## [Aquí puedes comparar costos de recursos de `AWS`](https://instances.vantage.sh/)