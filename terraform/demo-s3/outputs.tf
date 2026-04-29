output "bucket_name" {
  value       = aws_s3_bucket.demo.bucket
  description = "The name of the demo S3 bucket"
}
