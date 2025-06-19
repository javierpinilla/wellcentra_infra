# Wellcentra_infra

### Carpetas:

```bash
api_gateway
ec2_private_bastion
rds
vpc
```

### Y aca una un tag en particular:

```bash
api_gateway=API
ec2_private_bastion=EC2
rds=RDS
vpc=VPC
```

### Para crear los recursos debemos combinar la Palabra Crear con el tag, ej:

```bash
"Crear RDS" creará los recursos de la vpc.
```

### Y para destruir los recursos, usamos Destroy con el tag, ej:

```bash
"Destroy RDS" destruirá los recursos del RDS.
```

### Hay que agregar 3 secrets en el repo:

AWS_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY \
AWS_REGION

**Con permisos para crear los recursos**