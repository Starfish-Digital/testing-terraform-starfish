module "s3" {
  source    = "./modules/s3"
  buckets   = var.buckets
  env       = var.env
  accountId = var.accountId
}

######################## VPC ###############################

module "vpc" {
  source                      = "./modules/vpc"
  vpc_name                    = var.vpc_name
  vpc_cidr                    = var.vpc_cidr
  availability_zones          = var.availability_zones
  private_subnets_cidr_blocks = var.private_subnets_cidr
  public_subnets_cidr_blocks  = var.public_subnets_cidr
  private_subnet_name         = var.private_subnet_name
  public_subnet_name          = var.public_subnet_name
  internet_gw_name            = var.internet_gw
  nat_gw_name                 = var.nat_gw
  elastic_ip_name             = var.elastic_ip
  public_rt_name              = var.public_rt
  private_rt_name             = var.private_rt
  logs_grp                    = var.logs_group
  vpc_logs_iam_role           = var.vpc_logs_iam_role
  vpc_logs_policy             = var.vpc_logs_policy
  public_nacl_rules           = var.public_nacl_rules
  private_nacl_rules          = var.private_nacl_rules
  env                         = var.env
  accountId                   = var.accountId
}


module "secrets_manager" {
  source    = "./modules/secret-manager"
  env       = var.env
  accountId = var.accountId
  secrets   = var.secrets
}


module "document-db" {
  source = "./modules/document-db"

  subnet_group_name               = var.subnet_group_name
  subnet_ids                      = [for subnet_id in [module.vpc.private_subnet_ids[2], module.vpc.private_subnet_ids[8]] : subnet_id]
  cluster_identifier              = var.cluster_identifier
  master_username                 = var.master_username
  master_password                 = var.master_password
  engine_version                  = var.engine_version
  vpc_security_group_ids          = [for sg_id in [module.app_sg.security_group_id] : sg_id]
  storage_encrypted               = var.storage_encrypted
  apply_immediately               = var.apply_immediately
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  instance_count                  = var.instance_count
  instance_class                  = var.instance_class
  tags                            = var.tags
  enabled_cloudwatch_logs_exports = [for log in var.enabled_cloudwatch_logs_exports : log]
  deletion_protection             = var.deletion_protection
  env                             = var.env
  accountId                       = var.accountId
}

module "kms_keys" {
  source    = "./modules/kms-keys"
  kms_keys  = var.kms_keys
  env       = var.env
  accountId = var.accountId
}

module "ecs_cluster" {
  source        = "./modules/ecs-cluster"
  cluster_names = var.cluster_names # Pass the full list here

  env       = var.env
  accountId = var.accountId
}

# Outputs for all ECS Clusters
output "ecs_cluster_names" {
  value = module.ecs_cluster.this_aws_ecs_cluster_names
}

output "ecs_cluster_arns" {
  value = module.ecs_cluster.this_aws_ecs_cluster_arns
}

module "ssm_parameters" {
  source     = "./modules/ssm-parameters"
  parameters = var.parameters

  env       = var.env
  accountId = var.accountId
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
  }
  required_version = ">= 1.1.7"
}

provider "aws" {
  region = var.aws_region
  alias  = "test"
  assume_role {
    role_arn = "arn:aws:iam::${var.accountId}:role/${var.env}-cross-account-infra-deployment-role"
  }
}

provider "aws" {
  region = var.aws_region
}

module "iam" {
  source = "./modules/iam"

  users = {
    for user in var.iam.users :
    user.name => {
      name        = user.name
      policy_name = user.policy_name
    }
  }

  roles = {
    for role in var.iam.roles :
    role.name => {
      name               = role.name
      assume_role_policy = role.assume_role_policy
      policy_name        = role.policy_name
    }
  }

  policies = {
    for policy in var.iam.policies :
    policy.name => {
      name        = policy.name
      description = policy.description
      policy      = policy.policy
    }
  }

  groups = {
    for group in var.iam.groups :
    group.name => {
      name = group.name
      user = group.user
    }
  }

  tags      = var.tags
  env       = var.env
  accountId = var.accountId
}

// Security Group 

module "app_sg" {
  source      = "./modules/security-groups"
  name        = "my-app-sg"
  description = "SG for my app"
  vpc_id      = module.vpc.vpc_id
  env         = var.env
  accountId   = var.accountId
}

module "db_sg" {
  source      = "./modules/security-groups"
  name        = "my-db-sg"
  description = "SG for my database"
  vpc_id      = module.vpc.vpc_id
  env         = var.env
  accountId   = var.accountId
}

module "app_sg_rules" {
  source            = "./modules/security-groups-rules"
  security_group_id = module.app_sg.security_group_id
  ingress_rules = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      cidr_blocks              = []
      description              = "Allow HTTPS from DB SG"
      source_security_group_id = module.db_sg.security_group_id
    }
  ]
  egress_rules = []
  env          = var.env
  accountId    = var.accountId
}

module "db_sg_rules" {
  source            = "./modules/security-groups-rules"
  security_group_id = module.db_sg.security_group_id
  ingress_rules = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      cidr_blocks              = []
      description              = "Allow PostgreSQL from App SG"
      source_security_group_id = module.app_sg.security_group_id
    }
  ]
  egress_rules = []
  env          = var.env
  accountId    = var.accountId
}

module "api_gateway" {
  source      = "./modules/api-gateway"
  api_configs = var.api_configs
  env         = var.env
  accountId   = var.accountId
  tags        = var.tags
}

module "waf" {
  source      = "./modules/waf"
  environment = var.environment
  api_configs = var.api_configs

  api_ids = {
    for key, config in var.api_configs : key => module.api_gateway.api_id[key]
  }
  stage_names = {
    for key, config in var.api_configs : key => module.api_gateway.stage_name[key]
  }

  env       = var.env
  accountId = var.accountId
  tags      = var.tags
}

locals {
  lambda_subnet_map = {
    "lambda_one" = [module.vpc.private_subnet_map[var.private_subnet_names["lambda_one"]]],
    "lambda_two" = [module.vpc.private_subnet_map[var.private_subnet_names["lambda_two"]]]
  }

  lambda_role_arn_map = {
    lambda_one = module.iam.lambda_role_arns["lambda_one"]
    lambda_two = module.iam.lambda_role_arns["lambda_two"]
  }

  # lambda_configs = {
  #   for lambda_key, lambda_config in var.lambda_configs :
  #   lambda_key => merge(lambda_config, {
  #     subnet_ids = local.lambda_subnet_map[lambda_key]
  #   })
  # }

  lambda_configs_with_roles = {
    for lambda_name, config in var.lambda_configs :
    lambda_name => merge(config, {
      subnet_ids = local.lambda_subnet_map[lambda_name]
      role_arn   = local.lambda_role_arn_map[lambda_name]
    })
  }
}

module "lambda" {
  source = "./modules/lambda"
  # vpc_id               = module.vpc.vpc_id
  # subnet_ids           = module.vpc.private_subnet_ids

  lambda_sg_ids = {
    lambda_one = [module.cw_logs_to_elk_sg.security_group_id]
    lambda_two = [module.man_cw_alarm_sg.security_group_id]
  }

  # ingress_cidr_blocks  = [module.vpc.vpc_cidr_block]
  lambda_configs = local.lambda_configs_with_roles
  env            = var.env
  accountId      = var.accountId
}

module "cw_logs_to_elk_sg" {
  source      = "./modules/security-groups"
  name        = var.security_group_names["cw_logs_to_elk"]
  description = "SG for my app"
  vpc_id      = module.vpc.vpc_id
  env         = var.env
  accountId   = var.accountId
}

module "man_cw_alarm_sg" {
  source      = "./modules/security-groups"
  name        = var.security_group_names["man_cw_alarm"]
  description = "SG for my database"
  vpc_id      = module.vpc.vpc_id
  env         = var.env
  accountId   = var.accountId
}

module "cw_logs_to_elk_sg_rules" {
  source            = "./modules/security-groups-rules"
  security_group_id = module.cw_logs_to_elk_sg.security_group_id
  ingress_rules = [for rule in var.cw_logs_to_elk_sg_ingress_rules : merge(rule, {
    source_security_group_id = rule.description == "Allow HTTPS from DB SG" ? module.man_cw_alarm_sg.security_group_id : rule.source_security_group_id
  })]
  egress_rules = [for rule in var.cw_logs_to_elk_sg_egress_rules : merge(rule, {
    source_security_group_id = rule.description == "Allow HTTPS from DB SG" ? module.man_cw_alarm_sg.security_group_id : rule.source_security_group_id
  })]
  env       = var.env
  accountId = var.accountId
}

module "man_cw_alarm_sg_rules" {
  source            = "./modules/security-groups-rules"
  security_group_id = module.man_cw_alarm_sg.security_group_id
  ingress_rules = [for rule in var.man_cw_alarm_sg_ingress_rules : merge(rule, {
    source_security_group_id = rule.description == "Allow PostgreSQL from App SG" ? module.cw_logs_to_elk_sg.security_group_id : rule.source_security_group_id
  })]
  egress_rules = [for rule in var.man_cw_alarm_sg_egress_rules : merge(rule, {
    source_security_group_id = rule.description == "Allow HTTPS from DB SG" ? module.man_cw_alarm_sg.security_group_id : rule.source_security_group_id
  })]
  env       = var.env
  accountId = var.accountId
}

locals {
  launch_template_configs = [
    for lt in var.launch_templates : merge(
      lt,
      {
        iam_instance_profile_name = module.iam.instance_profile_names[lt.role_name]
      }
    )
  ]
}

module "launch_template" {
  source                 = "./modules/launch-template"
  launch_templates       = local.launch_template_configs
  vpc_security_group_ids = [module.app_sg.security_group_id]
  env                    = var.env
  accountId              = var.accountId
}


module "key_pair" {
  source    = "./modules/key_pair"
  key_pairs = var.key_pairs
  env       = var.env
  accountId = var.accountId
}

module "auto_scaling_group" {
  source = "./modules/auto-scaling-group"

  auto_scaling_groups = [
    for asg in var.auto_scaling_groups : merge(
      asg,
      {
        launch_template_id = module.launch_template.launch_template_ids[asg.launch_template_name],
        subnet_ids         = [module.my_vpc.subnet_name_to_id[asg.subnet_name]]
      }
    )
  ]

  env       = var.env
  accountId = var.accountId
}