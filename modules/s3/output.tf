output "bucket_arns" {
  value = { for bucket in aws_s3_bucket.this : bucket.id => bucket.arn }
}
