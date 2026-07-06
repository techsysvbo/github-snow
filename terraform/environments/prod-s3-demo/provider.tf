provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "github-snow"
      Environment = "prod-s3-demo"
      ManagedBy   = "terraform"
      Owner       = "CCoE"
      Purpose     = "GitHub-SNOW demonstration"
    }
  }
}
