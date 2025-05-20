variable "auto_scaling_groups" {
  description = "List of Auto Scaling Groups to create"
  type = list(object({
    name                     = string
    launch_template_id       = string
    min_size                 = number
    max_size                 = number
    desired_capacity         = number
    subnet_ids               = list(string)
    health_check_type         = string
    force_delete              = bool
    min_healthy_percentage   = number
    max_healthy_percentage   = number
    tags                     = map(string)
    lifecycle_hook = optional(object({
      name                    = string
      lifecycle_transition    = string
      default_result          = string
      heartbeat_timeout       = number
    }))
  }))
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "accountId" {
  description = "AWS Account ID"
  type        = string
}
