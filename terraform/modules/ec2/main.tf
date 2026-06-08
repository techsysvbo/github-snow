# 7yo: This builds one safe little computer.
# SME: EC2 is hardened for Checkov/NIST-style controls:
# - No public IP
# - IMDSv2 required
# - EBS encryption
# - EBS optimized
# - Detailed monitoring enabled
# - IAM instance profile attached

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile
  monitoring                  = true
  ebs_optimized               = true

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = var.tags
}
