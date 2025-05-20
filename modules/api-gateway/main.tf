terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_api_gateway_rest_api" "this" {
  for_each    = { for param in var.api_configs : param.api_name => param }
  name        = var.api_configs[each.key].api_name
  description = var.api_configs[each.key].description
  body        = file(each.value.swagger_path)

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  provider = aws.test
  tags   = var.tags
}

resource "aws_api_gateway_deployment" "this" {
  for_each    = aws_api_gateway_rest_api.this
  rest_api_id = aws_api_gateway_rest_api.this[each.key].id

   triggers = {
  redeployment = sha1(file(var.api_configs[each.key].swagger_path))
}

  lifecycle {
    create_before_destroy = true
  }
  provider = aws.test
}

resource "aws_api_gateway_stage" "this" {
  for_each = aws_api_gateway_rest_api.this
  rest_api_id   = aws_api_gateway_rest_api.this[each.key].id
  stage_name    = var.api_configs[each.key].stage_name
  deployment_id = aws_api_gateway_deployment.this[each.key].id
  variables = var.api_configs[each.key].stage_variables
  provider = aws.test
}

resource "aws_api_gateway_method_settings" "logs_and_tracing" {
  depends_on = [aws_api_gateway_stage.this]
  for_each = aws_api_gateway_rest_api.this
  rest_api_id = aws_api_gateway_rest_api.this[each.key].id
  stage_name  = var.api_configs[each.key].stage_name
  method_path = "*/*" # Applies to all methods and resources

  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
  provider = aws.test
}



