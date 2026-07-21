# AWS GovCloud S3-only production deployment.
#
# Values are supplied by the existing GitHub workflow:
#
# TF_VAR_aws_region
#   → variable "aws_region"
#
# TF_VAR_bucket_name
#   → variable "bucket_name"

module "vbo_tags" {
  source = "../../modules/vbo-tags"
}

module "s3_demo" {
  source = "../../modules/s3-demo"

  bucket_name = var.bucket_name
  tags        = module.vbo_tags.tags
}