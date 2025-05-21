terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }

  required_version = ">= 1.1.7"
}

resource "tls_private_key" "pk" {
  for_each = {
    for kp in var.key_pairs : kp.key_name => kp
    if kp.create_key_pair
  }

  algorithm = each.value.key_algorithm
  rsa_bits  = each.value.rsa_bits
  provider  = tls
}

resource "aws_key_pair" "kp" {
  for_each = tls_private_key.pk

  key_name   = each.key
  public_key = each.value.public_key_openssh
  provider   = aws.test

  tags = lookup({ for kp in var.key_pairs : kp.key_name => kp.tags }, each.key, {})

  provisioner "local-exec" {
    command = "echo '${each.value.private_key_pem}' > ${each.key}.pem && chmod 400 ${each.key}.pem"
  }
}

resource "aws_s3_object" "pem_upload" {
  for_each = {
    for kp in var.key_pairs : kp.key_name => kp
    if kp.create_key_pair && kp.upload_to_s3
  }

  bucket  = each.value.s3_bucket_name
  key     = "key-pairs/${each.key}.pem"
  content = tls_private_key.pk[each.key].private_key_pem
  provider = aws.test

  tags = each.value.tags
}
