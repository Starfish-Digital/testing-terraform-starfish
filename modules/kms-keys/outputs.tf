output "kms_key_ids" {
  value = aws_kms_key.this[*].id
}

output "kms_aliases" {
  value = aws_kms_alias.this[*].name
}
