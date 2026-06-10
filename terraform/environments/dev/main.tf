# 7yo: Dev uses the shared S3 toy box and EC2 toy computer modules.
# SME: Dev root stack calls reusable modules. This produces one check: terraform-checks (dev).

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_iam_role" "ec2_ssm" {
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

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "github-snow-dev-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = var.bucket_name
  tags        = local.common_tags
}

module "ec2" {
  source               = "../../modules/ec2"
  ami_id               = data.aws_ami.al2023.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  tags                 = local.common_tags
}
