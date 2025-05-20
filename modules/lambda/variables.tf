variable "lambda_configs" {
  type = map(object({
    function_name       = string
    handler             = string
    runtime             = string
    filename            = string
    subnet_ids          = list(string)
    tags                = map(string)
    role_arn     = string
    # policy_statements   = list(object({
    #   effect    = string
    #   actions   = list(string)
    #   resources = list(string)
    # }))
  }))
}

# variable "vpc_id" {
#   type = string
# }

# variable "subnet_ids" {
#   type = list(string)
# }

variable "lambda_sg_ids" {
  type = map(list(string))
}


# variable "ingress_cidr_blocks" {
#   type = list(string)
# }

variable "env" {
  description = "Envionment name"
  type        = string
}

variable "accountId" {
  description = "AccountId of AWS account"
  type        = string
}

