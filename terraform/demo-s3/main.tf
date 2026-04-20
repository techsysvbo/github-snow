provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "demo" { bucket = "snow-github-demo-${random_id.suffix.hex}" }
resource "random_id" "suffix" { byte_length = 4 }
