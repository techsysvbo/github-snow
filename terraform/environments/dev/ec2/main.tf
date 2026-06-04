resource "aws_security_group" "dev" {
  name        = "github-snow-dev-ec2-sg"
  description = "Dev EC2 security group with no inbound access."
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "Allow outbound HTTPS for SSM and package operations."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "dev_ec2_ssm" {
  name = "github-snow-dev-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dev_ssm_core" {
  role       = aws_iam_role.dev_ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "dev_ec2" {
  name = "github-snow-dev-ec2-profile"
  role = aws_iam_role.dev_ec2_ssm.name
}

resource "aws_instance" "dev" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.dev.id]
  iam_instance_profile        = aws_iam_instance_profile.dev_ec2.name
  associate_public_ip_address = false
  monitoring                  = true
  ebs_optimized               = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
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
