module "ec2" {
  source        = "../../../modules/ec2"
  ami_id        = data.aws_ami.al2023.id
  instance_type = var.instance_type
  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Project     = "github-snow"
  }
}
