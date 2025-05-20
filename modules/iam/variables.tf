variable "users" {
  description = "Map of users"
  type = map(object({
    name        = string
    policy_name = string
  }))
}

variable "roles" {
  description = "Map of roles"
  type = map(object({
    name                    = string
    assume_role_policy = string
    policy_name             = string
  }))
}

variable "policies" {
  description = "Map of policies"
  type = map(object({
    name        = string
    description = string
    policy      = string
  }))
}

variable "groups" {
  description = "Map of IAM groups"
  type = map(object({
    name = string
    user = string
  }))
}


variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "Envionment name"
  type        = string
}

variable "accountId" {
  description = "AccountId of AWS account"
  type        = string
}
