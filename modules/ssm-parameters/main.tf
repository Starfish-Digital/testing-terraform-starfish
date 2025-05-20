terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_ssm_parameter" "this" {
  for_each    = { for param in var.parameters : param.name => param }

  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  value       = each.value.value
  provider    = aws.test
  tags = each.value.tags
}

