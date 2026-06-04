resource "aws_security_group" "dev" {
  name        = "github-snow-dev-ec2-sg"
  description = "Dev EC2 security group with no inbound access."
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_instance" "dev" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.dev.id]
  associate_public_ip_address = false
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name = "github-snow-dev-ec2"
  }
}
