# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔴 ENHANCEMENT: OPERATIONAL OUTPUTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 7yo: Show me what was created so we can use it for monitoring and backups.
#
# SME: ADDED: EC2 instance ID/ARN and KMS key outputs. These are needed for:
#      - Operational dashboards (CloudWatch, SSM Session Manager)
#      - DR/backup procedures (snapshot backups, state imports)
#      - Audit logging (resource tracking, change management)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

output "s3_bucket_id" {
  value = module.s3.bucket_id
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance deployed by Terraform"
  value       = module.ec2.instance_id
}

output "ec2_instance_arn" {
  description = "ARN of the EC2 instance deployed by Terraform"
  value       = module.ec2.instance_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for S3 bucket encryption"
  value       = module.s3.kms_key_arn
}

output "event_queue_arn" {
  description = "ARN of the SQS queue for S3 event notifications"
  value       = module.s3.event_queue_arn
}
