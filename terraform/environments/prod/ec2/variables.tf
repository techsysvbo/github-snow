variable "aws_region" {
  type        = string
  description = "AWS region for production resources."
  default     = "us-east-1"
}

variable "application" {
  type        = string
  description = "Application name."
  default     = "github-snow"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "prod"
}

variable "owner" {
  type        = string
  description = "Owning team."
  default     = "CCoE"
}

variable "data_classification" {
  type        = string
  description = "Data classification."
  default     = "internal"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}
