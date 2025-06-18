# VPC existente
data "aws_vpc" "existing_vpc" {
  filter {
    name = "tag:Name"
    values = [local.vpc_name]
  }
}

# RDS subnet group existente
data "aws_db_subnet_group" "rds_subnet_group" {
  name = local.rds_subnet_group_name
}

# SG Existente para rds
data "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id
  filter {
    name = "tag:Name"
    values = ["${local.vpc_name}-rds-sg"]
  }
}

# SG Existente para EC2/Lambda
data "aws_security_group" "ec2_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id
  filter {
    name = "tag:Name"
    values = ["${local.vpc_name}-ec2-lambda-sg"]
  }
}

# Subredes privadas para ubicar EC2
data "aws_subnet" "private_subnets" {
  count = 3
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
  filter {
    name = "tag:Name"
    values = ["${local.vpc_name}-private-subnet-${count.index + 1}"]
  }
}

# Secret Manager para RDS
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds/${var.environment}/${var.rds_name}"
  description = "Credenciales para RDS"

  tags = merge(var.common_tags, {
    Name = "rds/${var.environment}/${var.rds_name}"
  })
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = "postgres"
    password = random_password.rds_password.result
  })
}

resource "random_password" "rds_password" {
  length = 16
  special = true
  override_special = "!#$%&()*+-./:;<=>?@[]^_`{|}~"
}

# Instancia de RDS
resource "aws_db_instance" "rds_instance" {
  identifier = local.rds_name
  allocated_storage = 20
  max_allocated_storage = 20
  storage_type = "gp3"
  engine = "postgres"
  engine_version = "17.5"
  instance_class = "db.t4g.micro"
  db_subnet_group_name = data.aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [data.aws_security_group.rds_sg.id]
  username = "postgres"
  password = random_password.rds_password.result
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately = true
  storage_encrypted = true

  tags = merge(var.common_tags, {
    Name = local.rds_name
  })
}

Crear DB
provider "postgresql" {
  alias = "rds"

  host = aws_db_instance.postgres.address
  port = aws_db_instance.postgres.port
  username = "postgres"
  password = random_password.rds_password.result
  sslmode = "require"
  connect_timeout = 15
  superuser = false
}

resource "time_sleep" "rds_wait" {
  create_duration = "10m"
  depends_on = [aws_db_instance.postgres]
}

resource "postgresql_database" "app_db" {
  provider = postgresql.rds

  name = var.rds_name
  owner = "postgres"
  encoding = "UTF8"
  lc_collate = "en_US.UTF-8"
  lc_ctype = "en_US.UTF-8"
  template = "template0"
  connection_limit = -1
  allow_connections = true

  depends_on = [time_sleep.rds_wait]
}

# Crear usuario igual que el nombre de la base
resource "postgresql_role" "app_user" {
  provider = postgresql.rds

  name = rds_db_name
  login = true
  password = random_password.app_db_password.result
}

# Otorgar privilegios
resource "postgresql_grant" "app_user_privs" {
  provider = postgresql.rds

  database = postgresql_database.app_db.name
  role = postgresql_role.app_user.name
  object_type = "database"
  privileges = ["CONNECT", "TEMPORARY", "CREATE"]
}

# Clave para usuario de base.
resource "random_password" "app_db_password" {
  length = 16
  special = false
}

# Secret Manager para el usuario de app de RDS
resource "aws_secretsmanager_secret" "rds_app_secret" {
  name = "app/${var.environment}/${var.vpc_name}"
  description = "Credenciales para usuario de RDS"

  tags = merge(var.common_tags, {
    Name = "app/${var.environment}/${var.vpc_name}"
  })
}

resource "aws_secretsmanager_secret_version" "rds_app_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_app_secret.id
  secret_string = jsonencode({
    username = "postgres"
    password = random_password.app_db_password.result
  })
}