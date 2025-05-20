output "user_names" {
  description = "The names of the IAM users"
  value       = keys(aws_iam_user.this)
}

output "role_names" {
  description = "The names of the IAM roles"
  value       = keys(aws_iam_role.this)
}

output "policy_names" {
  description = "The names of the IAM policies"
  value       = keys(aws_iam_policy.this)
}

output "group_names" {
  description = "IAM group names"
  value       = [for g in aws_iam_group.this : g.name]
}

output "instance_profile_names" {
  value = {
    for k, v in aws_iam_instance_profile.this : k => v.name
  }
}

output "lambda_role_arns" {
  description = "Map of lambda role names to their ARNs"
  value = {
    for role_key, role in aws_iam_role.this :
    role_key => role.arn
  }
}