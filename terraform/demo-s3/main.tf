provider "aws" {
  region = var.aws_region
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "demo" {
  bucket = "${var.bucket_prefix}-${random_id.suffix.hex}"

  tags = {
    Name        = "snow-github-demo"
    Environment = "production"
    ManagedBy   = "terraform"
    Repo        = "github-snow"
  }
}
