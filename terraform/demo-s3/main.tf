# This creates a safe S3 bucket for the lab.
# 7-year-old explanation:
# We are creating a locked storage box in AWS.

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 demo bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "logs" {
  bucket = "ccoe-snow-webhook-logs-${random_id.suffix.hex}"

  tags = {
    Project     = "GitHub-SNOW-Webhook"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "demo" {
  # checkov:skip=CKV_AWS_144:Cross-region replication is not required for this lab demo bucket.
  # checkov:skip=CKV_AWS_62:Event notifications are not required for this lab demo bucket.

  bucket = "ccoe-snow-webhook-demo-${random_id.suffix.hex}"

  tags = {
    Project     = "GitHub-SNOW-Webhook"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  # This blocks public internet access.
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  # This encrypts the bucket using KMS.
  bucket = aws_s3_bucket.demo.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "demo" {
  # This enables versioning.
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "demo" {
  # This enables access logging.
  bucket = aws_s3_bucket.demo.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "demo-access-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "demo" {
  # This adds lifecycle management.
  bucket = aws_s3_bucket.demo.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "demo" {
  # This makes the bucket owner control objects.
  bucket = aws_s3_bucket.demo.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
