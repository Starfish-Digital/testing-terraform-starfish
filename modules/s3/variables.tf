
variable "buckets" {
  description = "List of S3 buckets with their configurations."
  type = list(object({
    bucket_name       = string
    force_destroy     = bool
    additional_grants = list(object({
      id          = string
      permissions = list(string)
      type        = string
    }))
    lifecycle_rules = list(object({
      id           = string
      enabled      = bool
      prefix       = string
      expiration   = object({
        days                         = number
        expired_object_delete_marker = bool
        date                         = string
      })
      noncurrent_version_expiration = object({
        noncurrent_days = number
      })
      transitions = list(object({
        days          = number
        storage_class = string
      }))
      abort_incomplete_multipart_upload = object({
        days_after_initiation = number
      })
    }))
    acl              = string
    log_to_self = bool
    is_logging_bucket = bool
    control_object_ownership  = bool
    object_ownership          = string
    tags        = map(string)
  }))
  
}

variable "env" {
  description = "Envionment name"
  type        = string
}

variable "accountId" {
  description = "AccountId of AWS account"
  type        = string
}
