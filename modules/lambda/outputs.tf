output "lambda_function_names" {
  description = "Names of the Lambda functions"
  value       = { for k, v in aws_lambda_function.lambda : k => v.function_name }
}







