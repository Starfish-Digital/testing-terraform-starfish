variable "kms_keys" {
  description = "List of KMS keys"
  type = list(object({
    name             = string
    description      = string
    key_usage        = string
    customer_managed = bool
    enable_key_rotation = bool
    tags            = map(string)
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