variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "application" {
  type    = string
  default = "github-snow"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "CCoE"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
