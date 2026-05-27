provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
      Owner       = "CCoE"
      Application = "github-snow-demo"
    }
  }
}
