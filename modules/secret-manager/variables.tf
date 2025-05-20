variable "secrets" {
  description = "Secrets"
  type = list(object({
    name  = string
    description = string
    value = map(string)
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