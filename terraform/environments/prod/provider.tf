provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = "github-snow"
    Environment = "prod"
    ManagedBy   = "terraform"
    Owner       = "CCoE"
  }
}
