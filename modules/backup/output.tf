output "backup_bucket_url" {
  value = length(aws_s3_bucket.backup_bucket) > 0 ? aws_s3_bucket.backup_bucket[0].id : ""
}
