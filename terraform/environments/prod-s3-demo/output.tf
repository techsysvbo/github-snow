output "s3_bucket_name" {
  description = "Name of the deployed S3 bucket."
  value       = module.s3_demo.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the deployed S3 bucket."
  value       = module.s3_demo.bucket_arn
}

output "s3_bucket_id" {
  description = "ID of the deployed S3 bucket."
  value       = module.s3_demo.bucket_id
}

output "vbo_tags" {
  description = "Standard VBO tags applied to the S3 bucket."
  value       = module.vbo_tags.tags
}