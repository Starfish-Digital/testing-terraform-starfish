terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }

  required_version = ">= 0.13"
}

# Use locals for role mapping too
locals {
  users_map    = { for user in var.users : user.name => user }
  roles_map    = { for role in var.roles : role.name => role }
  policies_map = { for policy in var.policies : policy.name => policy }
}

# IAM Users
resource "aws_iam_user" "this" {
  for_each = local.users_map
  name     = each.value.name
  tags     = var.tags
  provider = aws.test
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name               = each.value.name
  assume_role_policy = each.value.assume_role_policy
  tags               = var.tags
  provider = aws.test
}


# IAM Policies
resource "aws_iam_policy" "this" {
  for_each    = local.policies_map
  name        = each.value.name
  description = each.value.description
  policy      = each.value.policy
  tags        = var.tags
  provider    = aws.test
}

# IAM User Policy Attachments
resource "aws_iam_user_policy_attachment" "this" {
  for_each   = local.users_map
  user       = aws_iam_user.this[each.key].name
  policy_arn = aws_iam_policy.this[each.value.policy_name].arn
  provider   = aws.test
}

# IAM Role Policy Attachments
resource "aws_iam_role_policy_attachment" "this" {
  for_each   = local.roles_map
  role       = aws_iam_role.this[each.key].name
  policy_arn = aws_iam_policy.this[each.value.policy_name].arn
  provider   = aws.test
}

# IAM Groups
resource "aws_iam_group" "this" {
  for_each = { for group in var.groups : group.name => group }
  name     = each.value.name
  provider = aws.test
}

# IAM Group Memberships
resource "aws_iam_group_membership" "this" {
  for_each = { for group in var.groups : group.name => group }
  name     = "${each.key}-membership"
  users    = [each.value.user]
  group    = aws_iam_group.this[each.key].name
  provider = aws.test
}

resource "aws_iam_instance_profile" "this" {
  for_each = var.roles

  name = "${each.value.name}-instance-profile"
  role = each.value.name
  provider = aws.test
}
