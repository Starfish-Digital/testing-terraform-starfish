variable "key_pairs" {
  description = "List of key pairs to create"
  type = list(object({
    key_name      = string
    key_algorithm = string
    rsa_bits      = number
    create_key_pair = bool
    tags          = map(string)
    upload_to_s3    = bool
    s3_bucket_name  = string
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