# Wellcentra_infra

#### Carpetas:

##### api_gateway \\
##### ec2_private_bastion \\
##### rds \\
##### vpc

#### Y aca una un tag en particular:

##### api_gateway=API \\
##### ec2_private_bastion=EC2 \\
##### rds=RDS \\
##### vpc=VPC

### Para crear los recursos debemos combinar la Palabra Crear con el tag, ej:

```bash
"Crear RDS" creará los recursos de la vpc.
```

### Y para destruir los recursos, usamos Destroy con el tag, ej:

```bash
"Destroy RDS" destruirá los recursos del RDS.
```