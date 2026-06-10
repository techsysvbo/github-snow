output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "logs_bucket_id" {
  value = aws_s3_bucket.logs.id
}

output "replica_bucket_id" {
  value = aws_s3_bucket.replica.id
}

output "kms_key_arn" {
  value = aws_kms_key.this.arn
}

output "event_queue_arn" {
  value = aws_sqs_queue.events.arn
}
