variable "launch_templates" {
  description = "List of launch templates to create"
  type = list(object({
    name                    = string
    ami_id                  = string
    description             = string
    instance_type           = string
    key_name                = string
    disable_api_stop        = bool
    disable_api_termination = bool
    tags                    = map(string)
    instance_tag            = string
    volume_tag              = string
    metadata_options = object({
      http_tokens = string
    })
    user_data                 = string
    role_name                 = string
    iam_instance_profile_name = string
  }))
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "accountId" {
  description = "AWS account ID"
  type        = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}
