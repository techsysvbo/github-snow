variable "aws_region" {
  description = "AWS Region supplied by the GitHub production environment."
  type        = string
}

variable "bucket_name" {
  description = "Exact S3 bucket name supplied by the GitHub production environment."
  type        = string
}