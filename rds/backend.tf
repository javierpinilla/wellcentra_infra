terraform {
  backend "s3" {
    bucket  = "wellcentra-infra-state"
    key     = "terraform/wellcentra/vpc/state"
    region  = "us-east-1"
    encrypt = true
  }

  # Also save a local copy
  backend "local" {
    path = "terraform.tfstate"
  }
}