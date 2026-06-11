terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    key     = "github-snow/prod/terraform.tfstate"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}
