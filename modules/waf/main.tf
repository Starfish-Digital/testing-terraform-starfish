terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_wafv2_web_acl" "this" {
  name        = "${var.environment}-web-acl"
  description = "QA environment WAF ACL with custom rules"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "qaWebAcl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "qa-amazon-ip-reputation-list"
    priority = 0
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaAmazonIpReputation"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-anonymous-ip-list"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-known-bad-inputs-rule-set"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaKnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-linux-rule-set"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-sqli-rule-set"
    priority = 4
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-unix-rule-set"
    priority = 5
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaUnixRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-php-rule-set"
    priority = 6
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaPHPRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-wordpress-rule-set"
    priority = 7
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesWordPressRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaWordPressRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-rate-limit-40-per-minute-waf-rule"
    priority = 8
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 40
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaRateLimit40PerMinute"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-rate-limit-10-per-minute-waf-rule"
    priority = 9
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 10
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaRateLimit10PerMinute"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "qa-rate-limit-40-per-5-minute-waf-rule"
    priority = 10
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 40
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "qaRateLimit40Per5Min"
      sampled_requests_enabled   = true
    }
  }
  provider = aws.test
  tags   = var.tags
}

resource "aws_wafv2_web_acl_association" "this" {
  for_each = var.api_configs

  resource_arn = "arn:aws:apigateway:ap-southeast-1::/restapis/${var.api_ids[each.key]}/stages/${var.stage_names[each.key]}"
  web_acl_arn  = aws_wafv2_web_acl.this.arn
  provider = aws.test
}

