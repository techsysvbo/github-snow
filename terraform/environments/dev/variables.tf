variable "aws_region" {
  description = "AWS region for dev."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique dev S3 bucket name."
  type        = string
  default     = "github-snow-dev-demo"
}

variable "instance_type" {
  description = "EC2 instance type for dev."
  type        = string
  default     = "t3.micro"
}
