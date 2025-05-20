variable "env" {
  description = "Envionment name"
  type        = string
}

variable "accountId" {
  description = "AccountId of AWS account"
  type        = string
}

#---- vpc variables ---

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones for subnets"
  type    = list(string)
}

variable "private_subnets_cidr_blocks" {
  description = "A list of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets_cidr_blocks" {
  description = "A list of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_name" {
  description = "private subnet name"
  type        = list(string)
}

variable "public_subnet_name" {
  description = "public subnet name"
  type        = list(string)
}

variable "internet_gw_name" {
  description = "internet gateway name"
  type        = string
}

variable "nat_gw_name" {
  description = "nat gateway name"
  type        = string
}
variable "elastic_ip_name" {
  description = "elastic ip name"
  type        = string
}
variable "public_rt_name" {
  description = "public subnet name"
  type        = string
}

variable "private_rt_name" {
  description = "private route table name"
  type        = string
}

# variable "ap_southeast_1a_private_subnet_id" {
#   description = "ap-southeast-1a subnet id"
#   type        = string
#   default     = null
# }

# variable "ap_southeast_1a_public_subnet_id" {
#   description = "ap-southeast-1a subnet id"
#   type        = string
#   default     = null
# }

variable "logs_grp" {
  description = "vpc access cloudwatch logs group"
  type        = string
}
variable "vpc_logs_iam_role" {
  description = "vpc logs iam role"
  type        = string
}

variable "vpc_logs_policy" {
  description = "vpc logs policy"
  type        = string
}

# Map of Public NACL Rules
variable "public_nacl_rules" {
  type = map(object({
    ingress = list(object({
      rule_number    = number
      protocol       = string
      rule_action    = string
      cidr_block     = string
      from_port      = number
      to_port        = number
    }))
    egress = list(object({
      rule_number    = number
      protocol       = string
      rule_action    = string
      cidr_block     = string
      from_port      = number
      to_port        = number
    }))
  }))
}

# Map of Private NACL Rules
variable "private_nacl_rules" {
  type = map(object({
    ingress = list(object({
      rule_number    = number
      protocol       = string
      rule_action    = string
      cidr_block     = string
      from_port      = number
      to_port        = number
    }))
    egress = list(object({
      rule_number    = number
      protocol       = string
      rule_action    = string
      cidr_block     = string
      from_port      = number
      to_port        = number
    }))
  }))
}

# variable "subnet_rule_number_mapping" {
#   description = "Mapping of subnet names to base rule numbers"
#   type = map(number)
# }

# variable "subnet_to_nacl_mapping" {
#   description = "Mapping of subnet names to NACL indices"
#   type        = map(number)
# }
