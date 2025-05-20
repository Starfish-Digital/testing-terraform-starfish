output "secret_arn" {
  description = "The ARN of the created secret"
  value       = { for name, secret in aws_secretsmanager_secret.example : name => secret.arn }
}

output "secret_name" {
  description = "The name of the created secret"
  value       = { for name, secret in aws_secretsmanager_secret.example : name => secret.name }
}

