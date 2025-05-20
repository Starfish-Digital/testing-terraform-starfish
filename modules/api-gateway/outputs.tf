output "api_id" {
  value = { for k, v in aws_api_gateway_rest_api.this : k => v.id }
}

output "execution_arn" {
  value = { for k, v in aws_api_gateway_rest_api.this : k => v.execution_arn }
}

output "stage_name" {
  value = {
    for k, v in aws_api_gateway_stage.this : k => v.stage_name
  }
}
