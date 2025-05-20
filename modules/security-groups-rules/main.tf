terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.ingress_rules)
 
  provider          = aws.test
  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  description       = var.ingress_rules[count.index].description
  security_group_id = var.security_group_id
 
  cidr_blocks              = length(var.ingress_rules[count.index].cidr_blocks) > 0 ? var.ingress_rules[count.index].cidr_blocks : null
  source_security_group_id = var.ingress_rules[count.index].source_security_group_id != "" ? var.ingress_rules[count.index].source_security_group_id : null
}
 
resource "aws_security_group_rule" "egress" {
  count = length(var.egress_rules)
 
  provider          = aws.test
  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  description       = var.egress_rules[count.index].description
  security_group_id = var.security_group_id
 
  cidr_blocks              = length(var.egress_rules[count.index].cidr_blocks) > 0 ? var.egress_rules[count.index].cidr_blocks : null
  source_security_group_id = var.egress_rules[count.index].source_security_group_id != "" ? var.egress_rules[count.index].source_security_group_id : null
}
