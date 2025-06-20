terraform {
  backend "s3" {
    bucket       = "wellcentra-infra-state"
    key          = "terraform/wellcentra/dev/rds/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}