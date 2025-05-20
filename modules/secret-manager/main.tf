terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_secretsmanager_secret" "example" {  
  for_each = { for secret_name in var.secrets : secret_name.name => secret_name }
  name     = each.value.name
  description = each.value.description
  recovery_window_in_days = 0
  provider = aws.test
}

resource "aws_secretsmanager_secret_version" "example" {
  for_each      = { for secret_name in var.secrets : secret_name.name => secret_name }
  secret_id     = aws_secretsmanager_secret.example[each.key].id
  secret_string = jsonencode(each.value.value)
  provider = aws.test
}
