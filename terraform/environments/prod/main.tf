# 7yo: Prod uses the same safe modules, but prod has its own names and tags.
# SME: Prod root stack creates one production validation/deployment unit.

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name = "github-snow-prod-ec2-ssm-role"

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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔴 SECURITY FIX #1: EC2 S3 + KMS PERMISSIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 7yo: Give the computer permission to read/write files in the storage bucket
#      and to unlock those files with the secret key.
#
# SME: CRITICAL: EC2 instance previously had SSM-only access. Without this policy,
#      the instance cannot interact with S3 buckets for data pipelines, backups, or
#      logging. Added least-privilege inline policy with explicit resource ARNs.
#      - S3: GetObject, PutObject, DeleteObject, ListBucket on specific bucket
#      - KMS: Decrypt, Encrypt, GenerateDataKey to use S3-side KMS encryption
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_iam_role_policy" "ec2_s3_access" {
  name = "github-snow-prod-ec2-s3-access"
  role = aws_iam_role.ec2_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${module.s3.bucket_arn}",
          "${module.s3.bucket_arn}/*"
        ]
      },
      {
        Sid    = "KMSKeyAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = [module.s3.kms_key_arn]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "github-snow-prod-ec2-profile"
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
