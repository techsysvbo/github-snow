# Temporary S3-only deployment demonstration.
# EC2, customer-managed KMS, SQS, replication, event notifications,
# lifecycle policy, and access logging are intentionally out of scope
# for this controlled demo stack.

resource "aws_s3_bucket" "demo" {
  #checkov:skip=CKV2_AWS_62:Temporary demo bucket; event notifications are out of scope.
  #checkov:skip=CKV_AWS_145:Temporary demo uses AWS-managed SSE-S3 encryption; no customer-managed KMS key is created.
  #checkov:skip=CKV2_AWS_61:Temporary demo bucket; lifecycle configuration is out of scope.
  #checkov:skip=CKV_AWS_144:Temporary demo bucket; cross-region replication is out of scope.
  #checkov:skip=CKV_AWS_18:Temporary demo bucket; access logging is out of scope.

  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "demo" {
  bucket = aws_s3_bucket.demo.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  bucket = aws_s3_bucket.demo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
