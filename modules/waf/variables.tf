variable "environment" {
  type = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "env" {
  description = "Envionment name"
  type        = string
}

variable "accountId" {
  description = "AccountId of AWS account"
  type        = string
}

variable "api_configs" {
  description = "Map of API Gateway configurations"
  type = map(object({
    api_name        = string
    description     = string
    swagger_path    = string
    stage_name      = string
    stage_variables = map(string)
  }))
}

variable "api_ids" {
  type = map(string)
}

variable "stage_names" {
  type = map(string)
}
