terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_s3_bucket" "this" {
  for_each      = { for bucket in var.buckets : bucket.bucket_name => bucket }
  bucket        = each.value.bucket_name
  force_destroy = each.value.force_destroy
  provider = aws.test
  tags = each.value.tags
}

locals {
  buckets_with_lifecycle_rules = { for bucket in var.buckets : bucket.bucket_name => bucket if length(bucket.lifecycle_rules) > 0 }
  logging_bucket_list = [for bucket in var.buckets : bucket if bucket.is_logging_bucket]
  buckets_to_enable_logging = {
    for bucket in var.buckets : bucket.bucket_name => bucket
    if !bucket.is_logging_bucket || (bucket.is_logging_bucket && lookup(bucket, "log_to_self", false))
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  provider = aws.test
  for_each = local.buckets_with_lifecycle_rules
  bucket = each.value.bucket_name
  depends_on = [aws_s3_bucket.this]
  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      filter {
        prefix = rule.value.prefix
      }
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = rule.value.expiration.days
          expired_object_delete_marker = rule.value.expiration.expired_object_delete_marker
          date                         = rule.value.expiration.date
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }
      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }
  
}
resource "aws_s3_bucket_versioning" "this" {
  provider = aws.test
  for_each = { for bucket in var.buckets : bucket.bucket_name => bucket }
  bucket = each.value.bucket_name
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  provider = aws.test
  for_each = { for bucket in var.buckets : bucket.bucket_name => bucket }
  bucket = each.value.bucket_name
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_logging" "this" {
  provider = aws.test
  for_each = local.buckets_to_enable_logging
  bucket        = each.value.bucket_name
  target_bucket = local.logging_bucket_list[0].bucket_name
  target_prefix = "${each.value.bucket_name}/"

  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_policy" "this" {
  provider = aws.test
  for_each = { for bucket in var.buckets : bucket.bucket_name => bucket }
  bucket = each.value.bucket_name
  policy = jsonencode({
    Statement = [
      {
        Action = "s3:DeleteBucket"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = false
          }
        }
        Effect    = "Deny"
        Principal = "*"
        Resource  = "arn:aws:s3:::${each.value.bucket_name}"
      },
      {
        Action = "s3:*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
        Effect    = "Deny"
        Principal = "*"
        Resource  = [
          "arn:aws:s3:::${each.value.bucket_name}",
          "arn:aws:s3:::${each.value.bucket_name}/*"
        ]
      }
    ]
    Version = "2012-10-17"
  })
  depends_on = [aws_s3_bucket.this]
}

resource "aws_s3_bucket_ownership_controls" "this" {
  provider = aws.test
  for_each = { for bucket in var.buckets : bucket.bucket_name => bucket if bucket.control_object_ownership }
  bucket = each.value.bucket_name
  rule {
    object_ownership = each.value.object_ownership
  }
  depends_on = [aws_s3_bucket.this]
}
