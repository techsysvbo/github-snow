output "bucket_name" {
  value = aws_s3_bucket.dev.bucket
}

output "logs_bucket_name" {
  value = aws_s3_bucket.logs.bucket
}

output "replica_bucket_name" {
  value = aws_s3_bucket.replica.bucket
}

output "kms_key_arn" {
  value = aws_kms_key.dev_s3.arn
}
