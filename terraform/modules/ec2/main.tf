# 7yo: Builds one little computer with an encrypted drive and locked metadata.
# SME: EC2 with EBS encryption, IMDSv2 required, no public IP. Checkov-friendly.
resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = false
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = var.tags
}
