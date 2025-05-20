

variable "parameters" {
  description = "List of SSM parameters"
  type = list(object({
    name        = string
    description = string
    type        = string
    value       = string
    overwrite   = bool
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
