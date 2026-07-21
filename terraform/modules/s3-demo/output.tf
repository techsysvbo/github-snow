output "bucket_name" {
  description = "Name of the deployed S3 bucket."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the deployed S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID of the deployed S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "tags" {
  description = "Tags applied to the S3 bucket."
  value       = aws_s3_bucket.this.tags
}