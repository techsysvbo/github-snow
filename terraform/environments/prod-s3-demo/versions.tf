terraform {
  required_version = "~> 1.9.5"

  backend "s3" {
    key     = "github-snow/prod-s3-demo/terraform.tfstate"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}
