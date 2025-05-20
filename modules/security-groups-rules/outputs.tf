output "ingress_rule_count" {
  value = length(aws_security_group_rule.ingress)
}

output "egress_rule_count" {
  value = length(aws_security_group_rule.egress)
}
