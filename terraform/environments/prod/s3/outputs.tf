output "app_bucket_name" {
  description = "Production application S3 bucket name."
  value       = aws_s3_bucket.app.bucket
}

output "logs_bucket_name" {
  description = "Production access logs S3 bucket name."
  value       = aws_s3_bucket.logs.bucket
}

output "kms_key_arn" {
  description = "KMS key ARN."
  value       = aws_kms_key.s3.arn
}
