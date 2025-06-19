terraform {
  backend "s3" {
    bucket       = "wellcentra-infra-state"
    key          = "terraform/wellcentra/us-east-2/dev/api_gateway/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}