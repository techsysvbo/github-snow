variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for resources"
}

variable "bucket_prefix" {
  type        = string
  default     = "snow-github-demo-test-v2"
  description = "Prefix for S3 bucket names"
}
