region  = "us-east-2"
environment = "dev"
vpc_cidr_all = "0.0.0.0/0"
vpc_cidr = "10.20.0.0/16"
vpc_name = "wellcentra"

subnet_public_cidrs = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
subnet_private_cidrs= ["10.20.21.0/24", "10.20.22.0/24", "10.20.23.0/24"]
subnet_private_rds_cidrs = ["10.20.41.0/24", "10.20.42.0/24", "10.20.43.0/24"]

common_tags = {
  Project     = "Wellcentra"
  Environment = "Development"
  Owner       = "Devops"
}