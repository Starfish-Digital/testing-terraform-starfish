output "ssm_parameter_arns" {
  description = "ARNs of the created SSM Parameters"
  value       = { for key, param in aws_ssm_parameter.this : key => param.arn }
}

output "ssm_parameter_names" {
  description = "Names of the created SSM Parameters"
  value       = { for key, param in aws_ssm_parameter.this : key => param.name }
}
