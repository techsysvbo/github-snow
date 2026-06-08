resource "aws_iam_role" "ec2_ssm" {
  name = "github-snow-prod-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "github-snow-prod-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

module "ec2" {
  source = "../../../modules/ec2"

  ami_id               = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2.name

  tags = local.tags
}
