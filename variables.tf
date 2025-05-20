variable "buckets" {
  description = "List of S3 buckets with their configurations."
  type = list(object({
    bucket_name   = string
    force_destroy = bool
    additional_grants = list(object({
      id          = string
      permissions = list(string)
      type        = string
    }))
    lifecycle_rules = list(object({
      id      = string
      enabled = bool
      prefix  = string
      expiration = object({
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
    acl                      = string
    log_to_self              = bool
    is_logging_bucket        = bool
    control_object_ownership = bool
    object_ownership         = string
    tags                     = map(string)
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

variable "vpc_name" {
  description = "vpc name"
  type        = string
}

variable "public_subnet_name" {
  type = list(string)
}

variable "private_subnet_name" {
  type = list(string)
}

variable "internet_gw" {
  description = "internet gateway of vpc"
  type        = string
}

variable "nat_gw" {
  description = "nat gateway of vpc"
  type        = string
}

variable "elastic_ip" {
  description = "elastic ip of vpc"
  type        = string
}

variable "public_rt" {
  description = "public route table of vpc"
  type        = string
}

variable "private_rt" {
  description = "private route table of vpc"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones for subnets"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "A list of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets_cidr" {
  description = "A list of CIDR blocks for public subnets"
  type        = list(string)
}

variable "logs_group" {
  description = "logs group"
  type        = string
}

variable "vpc_logs_iam_role" {
  description = "iam role of vpc"
  type        = string
}

variable "vpc_logs_policy" {
  description = "logs policy of vpc"
  type        = string
}

# variable "subnet_rule_number_mapping" {
#   description = "Mapping of subnet names to their corresponding base rule numbers."
#   type        = map(number)
# }

# variable "subnet_to_nacl_mapping" {
#   description = "Mapping of subnet names to NACL indices"
#   type        = map(number)
# }

# Variables for Network ACL Rules

variable "public_nacl_rules" {
  type = map(object({
    ingress = list(object({
      rule_number = number
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    }))
    egress = list(object({
      rule_number = number
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    }))
  }))
}

variable "private_nacl_rules" {
  type = map(object({
    ingress = list(object({
      rule_number = number
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    }))
    egress = list(object({
      rule_number = number
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    }))
  }))
}

# --secret-maanger---

variable "secrets" {
  description = "Secrets"
  type = list(object({
    name        = string
    description = string
    value       = map(string)
  }))
}


#  ---document-db--

variable "subnet_group_name" {
  description = "The name of the DocumentDB subnet group"
  type        = string
}

#

variable "cluster_identifier" {
  description = "The identifier of the DocumentDB cluster"
  type        = string
}

variable "master_username" {
  description = "The master username for the DocumentDB cluster"
  type        = string
}

variable "master_password" {
  description = "The master password for the DocumentDB cluster"
  type        = string
  sensitive   = true
}

variable "engine_version" {
  description = "The engine version for the DocumentDB cluster"
  type        = string
}

variable "storage_encrypted" {
  description = "Specifies whether the DocumentDB storage is encrypted"
  type        = bool
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  type        = bool
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
}

variable "instance_count" {
  description = "The number of instances in the DocumentDB cluster"
  type        = number
}

variable "instance_class" {
  description = "The class of instances in the DocumentDB cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "myproject"
  }
}

# variable "final_snapshot_identifier" {
#   description = "The identifier for the final snapshot when the DocumentDB cluster is deleted"
#   type        = string
#   default     = ""  # Provide a default value or handle it in your tfvars file
# }


variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["audit", "profiler"]
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled"
  type        = bool
  default     = false
}

variable "iam" {
  description = "IAM configuration"
  type = object({
    users    = list(object({ name = string, policy_name = string })),
    roles    = list(object({ name = string, assume_role_policy = string, policy_name = string })),
    policies = list(object({ name = string, description = string, policy = string })),
    groups   = list(object({ name = string, user = string }))
  })
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "ap-southeast-1"
}

# --ecs---
# variable "ecs_cluster_name" {
#   description = "ECS cluster name"
#   type        = string
# }

# variable "ecs_instance_role" {
#   description = "ECS instance IAM role"
#   type        = string
# }

# variable "ecs_service_role" {
#   description = "ECS service IAM role"
#   type        = string
# }



# variable "ecs_ami_id" {
#   description = "AMI ID for the EC2 instance"
#   type        = string
# }

# variable "ecs_instance_type" {
#   description = "Instance type of ECS instance"
#   type        = string
# }

# variable "ebs_volume_type" {
#   description = "EBS volume type of EC2 instance"
#   type        = string
# }

# variable "ebs_volume_size" {
#   description = "EBS volume size of EC2 instance in GB"
#   type        = number
# }

# variable "auto_scaling_group_name" {
#   description = "Auto scaling group name"
#   type        = string
# }

# variable "ecs_ec2_instance_name" {
#   description = "ECS EC2 instance name"
#   type        = string
# }

# variable "ecs_capacitor_provider_name" {
#   description = "ECS capacitor provider"
#   type        = string
# }

# variable "max_scaling_step_size" {
#   description = "Maximum scaling step size of instance"
#   type        = number
# }

# variable "min_scaling_step_size" {
#   description = "Minimum scaling step size of instance"
#   type        = number
# }

# variable "ecs_desired_capacity" {
#   description = "Desired capacity of instance"
#   type        = number
# }

# variable "ecs_min_size" {
#   description = "Minimum size of ECS instance"
#   type        = number
# }

# variable "ecs_max_size" {
#   description = "Maximum size of ECS instance"
#   type        = number
# }

# variable "ecs_target_capacity" {
#   description = "ECS target capacity"
#   type        = number
# }

# AWS Cluster Variable
variable "cluster_names" {
  description = "List of ECS cluster names to be created"
  type        = list(string)
}

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

variable "kms_keys" {
  description = "List of KMS keys to create"
  type = list(object({
    name                = string
    description         = string
    key_usage           = string
    customer_managed    = bool
    enable_key_rotation = bool
    tags                = map(string)
  }))
}

variable "api_configs" {
  description = "Map of API Gateway configurations"
  type = map(object({
    api_name        = string
    description     = string
    swagger_path    = string
    stage_name      = string
    stage_variables = map(string)
    tags            = map(string)
  }))
}

variable "environment" {
  type = string
}

variable "cw_logs_to_elk_sg_ingress_rules" {
  description = "Ingress rules for app security group"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = list(string)
    description              = string
    source_security_group_id = optional(string)
  }))
}

variable "cw_logs_to_elk_sg_egress_rules" {
  description = "Egress rules for app security group"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = list(string)
    description              = string
    source_security_group_id = optional(string)
  }))
}


variable "man_cw_alarm_sg_ingress_rules" {
  description = "Ingress rules for app security group"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = list(string)
    description              = string
    source_security_group_id = optional(string)
  }))
}

variable "man_cw_alarm_sg_egress_rules" {
  description = "Egress rules for app security group"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = list(string)
    description              = string
    source_security_group_id = optional(string)
  }))
}


variable "lambda_configs" {
  type = map(object({
    function_name = string
    handler       = string
    runtime       = string
    filename      = string
    tags          = map(string)
    policy_statements = list(object({
      effect    = string
      actions   = list(string)
      resources = list(string)
    }))
  }))
}

variable "security_group_names" {
  type        = map(string)
  description = "Map of security group names"
}


variable "private_subnet_names" {
  type        = map(string)
  description = "Map of private subnet names for Lambda functions"
}

variable "key_pairs" {
  description = "List of key pairs to create"
  type = list(object({
    key_name        = string
    key_algorithm   = string
    rsa_bits        = number
    create_key_pair = bool
    tags            = map(string)
    upload_to_s3    = bool
    s3_bucket_name  = string
  }))
}

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
    user_data = string
    role_name = string
  }))
}

variable "auto_scaling_groups" {
  description = "List of Auto Scaling Groups to create"
  type = list(object({
    name                   = string
    launch_template_name   = string
    min_size               = number
    max_size               = number
    desired_capacity       = number
    subnet_name            = string
    health_check_type      = string
    force_delete           = bool
    min_healthy_percentage = number
    max_healthy_percentage = number
    tags                   = map(string)
    lifecycle_hook = optional(object({
      name                 = string
      lifecycle_transition = string
      default_result       = string
      heartbeat_timeout    = number
    }))
  }))
}