variable "ami_id" {
  description = "AMI ID used for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile" {
  description = "IAM instance profile name attached to the EC2 instance."
  type        = string
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
