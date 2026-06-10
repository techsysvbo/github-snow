variable "aws_region" {
  description = "AWS region for prod."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique prod S3 bucket name."
  type        = string
  default     = "github-snow-prod-demo"
}

variable "instance_type" {
  description = "EC2 instance type for prod."
  type        = string
  default     = "t3.micro"
}
