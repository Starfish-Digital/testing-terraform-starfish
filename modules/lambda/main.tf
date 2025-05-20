terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

# resource "aws_iam_policy" "lambda_custom_policy" {
#   for_each = var.lambda_configs

#   name = "${each.value.function_name}-custom-policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       for stmt in each.value.policy_statements : {
#         Effect   = stmt.effect
#         Action   = stmt.actions
#         Resource = stmt.resources
#       }
#     ]
#   })
#   provider = aws.test
# }

# resource "aws_iam_role" "lambda" {
#   for_each = var.lambda_configs

#   name = "${each.value.function_name}-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
#   provider = aws.test
#   tags = each.value.tags
# }

# resource "aws_iam_role_policy_attachment" "lambda_custom_policy_attachment" {
#   for_each = var.lambda_configs

#   role       = aws_iam_role.lambda[each.key].name
#   policy_arn = aws_iam_policy.lambda_custom_policy[each.key].arn
#   provider = aws.test
# }

resource "aws_lambda_function" "lambda" {
  for_each = var.lambda_configs

  function_name = each.value.function_name
  handler       = each.value.handler
  runtime       = each.value.runtime
  filename      = each.value.filename
  # role          = aws_iam_role.lambda[each.key].arn
  role          = each.value.role_arn

  vpc_config {
    subnet_ids         = each.value.subnet_ids
    security_group_ids = var.lambda_sg_ids[each.key]
  }
  provider = aws.test
  tags = each.value.tags
}

