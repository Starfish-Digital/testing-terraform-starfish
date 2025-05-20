terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_kms_key" "this" {
  count               = length(var.kms_keys)
  description         = var.kms_keys[count.index].description
  key_usage          = var.kms_keys[count.index].key_usage
  is_enabled         = true
  enable_key_rotation = var.kms_keys[count.index].enable_key_rotation
  customer_master_key_spec = var.kms_keys[count.index].customer_managed ? "SYMMETRIC_DEFAULT" : "ASYMMETRIC_RSA_2048"
  provider = aws.test
  tags = var.kms_keys[count.index].tags
}

resource "aws_kms_alias" "this" {
  count         = length(var.kms_keys)
  name          = "alias/${var.kms_keys[count.index].name}"
  target_key_id = aws_kms_key.this[count.index].id
  provider = aws.test
}
