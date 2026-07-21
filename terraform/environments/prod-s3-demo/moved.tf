moved {
  from = aws_s3_bucket.demo
  to   = module.s3_demo.aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_public_access_block.demo
  to   = module.s3_demo.aws_s3_bucket_public_access_block.this
}

moved {
  from = aws_s3_bucket_ownership_controls.demo
  to   = module.s3_demo.aws_s3_bucket_ownership_controls.this
}

moved {
  from = aws_s3_bucket_versioning.demo
  to   = module.s3_demo.aws_s3_bucket_versioning.this
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.demo
  to   = module.s3_demo.aws_s3_bucket_server_side_encryption_configuration.this
}