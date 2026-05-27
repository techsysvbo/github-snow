variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "name_prefix" {
  type    = string
  default = "ccoe-snow-prod-demo"
}
