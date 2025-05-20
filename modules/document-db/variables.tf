variable "env" {
  description = "Envionment name"
  type        = string
}
 
variable "accountId" {
  description = "AccountId of AWS account"
  type        = string
}


variable "subnet_group_name" {
  description = "The name of the subnet group"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the subnet group"
  type        = list(string)
}

variable "cluster_identifier" {
  description = "The cluster identifier"
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
  description = "The engine version to use"
  type        = string
  default     = "4.0.0"
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security groups to associate with the cluster"
  type        = list(string)
}

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The preferred backup window"
  type        = string
  default     = "07:00-09:00"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "The instance class to use"
  type        = string
  default     = "db.r5.large"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# variable "final_snapshot_identifier" {
#   description = "The identifier for the final snapshot when the DocumentDB cluster is deleted"
#   type        = string
#   default     = ""
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
