resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-sg"
  description = "Demo EC2 security group"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.this.id]

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.name_prefix}-ec2"
  }
}
