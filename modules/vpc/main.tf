terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}
#----- vpc ---

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  provider = aws.test
  tags = {
    Name = var.vpc_name
  }
}

# --- Public-Subnets ---
resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnets_cidr_blocks[count.index]
  availability_zone       = length(regexall("-1a", element(var.private_subnet_name, count.index))) > 0 ? element(var.availability_zones, 0) : element(var.availability_zones, 1)
  map_public_ip_on_launch = false
  provider                = aws.test
  tags = {
    Name = element(var.private_subnet_name, count.index)
  }
}

# --- Private-Subnets ---
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr_blocks)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidr_blocks[count.index]
  availability_zone       = length(regexall("-1a", element(var.public_subnet_name, count.index))) > 0 ? element(var.availability_zones, 0) : element(var.availability_zones, 1)
  map_public_ip_on_launch = true
  provider                = aws.test
  tags = {
    Name = element(var.public_subnet_name, count.index)
  }
}

#--- internet gateway ------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  provider = aws.test
  tags = {
    Name = var.internet_gw_name
  }
}

#---------- natgateway -----
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[2].id
  provider      = aws.test
   tags = {
    Name = var.nat_gw_name
  }
}

#---------- elastic ip -------
resource "aws_eip" "main" {
  provider = aws.test
  domain = "vpc"
  tags = {
    Name = var.elastic_ip_name
  }
}

#---- Public Route table: attach Internet Gateway ------- 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  provider                = aws.test
  tags = {
    Name = var.public_rt_name
  }
}

#################### Create a private route table ############
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  provider  = aws.test
  tags = {
    Name = var.private_rt_name
  }
}

############# Associate the public route table with public subnets#######
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
  provider       = aws.test
}

############# Associate the private route table with private subnets #############
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
  provider       = aws.test
}

# --- Network ACLs ---

resource "aws_network_acl" "public" {
 count  = length(aws_subnet.public)
  vpc_id = aws_vpc.main.id
  provider       = aws.test
  tags = {
    Name = "${element(var.public_subnet_name, count.index)}-nacl"
  }
}

resource "aws_network_acl_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  network_acl_id = aws_network_acl.public[count.index].id
  provider       = aws.test
}

resource "aws_network_acl" "private" {
  count  = length(aws_subnet.private) 
  vpc_id = aws_vpc.main.id
  provider       = aws.test
  tags = {
    Name ="${element(var.private_subnet_name, count.index)}-nacl"
  }
}

resource "aws_network_acl_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  network_acl_id = aws_network_acl.private[count.index].id
  provider       = aws.test
}

locals {
  public_ingress_rules = flatten([
    for subnet_name, rules in var.public_nacl_rules : [
      for rule in rules.ingress : {
        nacl_name   = "${subnet_name}-nacl"
        rule        = rule
        type        = "ingress"
      }
    ]
  ])

  public_egress_rules = flatten([
    for subnet_name, rules in var.public_nacl_rules : [
      for rule in rules.egress : {
        nacl_name   = "${subnet_name}-nacl"
        rule        = rule
        type        = "egress"
      }
    ]
  ])

  private_ingress_rules = flatten([
    for subnet_name, rules in var.private_nacl_rules : [
      for rule in rules.ingress : {
        nacl_name   = "${subnet_name}-nacl"
        rule        = rule
        type        = "ingress"
      }
    ]
  ])

  private_egress_rules = flatten([
    for subnet_name, rules in var.private_nacl_rules : [
      for rule in rules.egress : {
        nacl_name   = "${subnet_name}-nacl"
        rule        = rule
        type        = "egress"
      }
    ]
  ])
}


# --- Dynamically create NACL rules for Public Subnets ---
resource "aws_network_acl_rule" "public_ingress" {
  for_each = {
    for idx, rule_data in local.public_ingress_rules : 
    "${rule_data.nacl_name}_ingress_${idx}" => rule_data
  }
  # network_acl_id = aws_network_acl.public[lookup(var.subnet_to_nacl_mapping, each.value.subnet_name)].id
  #network_acl_id = aws_network_acl.public[index(aws_network_acl.public[*].tags.Name, each.value.nacl_name)].id
  network_acl_id = lookup(
  { for nacl in aws_network_acl.public : nacl.tags.Name => nacl.id },
  each.value.nacl_name,
  null
)
  rule_number    = lookup(each.value.rule, "rule_number", 100) 
  protocol       = lookup(each.value.rule, "protocol", "tcp")
  rule_action    = lookup(each.value.rule, "rule_action", "allow")
  cidr_block     = lookup(each.value.rule, "cidr_block", "0.0.0.0/0")
  from_port      = lookup(each.value.rule, "from_port", 0)
  to_port        = lookup(each.value.rule, "to_port", 0)
  egress         = false
  provider       = aws.test

  depends_on = [aws_network_acl.public]
}

resource "aws_network_acl_rule" "public_egress" {
  for_each = {
    for idx, rule_data in local.public_egress_rules : 
    "${rule_data.nacl_name}_egress_${idx}" => rule_data
  }
  # network_acl_id = aws_network_acl.public[lookup(var.subnet_to_nacl_mapping, each.value.subnet_name)].id
  #network_acl_id = aws_network_acl.public[index(aws_network_acl.public[*].tags.Name, each.value.nacl_name)].id
  network_acl_id = lookup(
  { for nacl in aws_network_acl.public : nacl.tags.Name => nacl.id },
  each.value.nacl_name,
  null
)
  rule_number    = lookup(each.value.rule, "rule_number", 100) 
  protocol       = lookup(each.value.rule, "protocol", "tcp")
  rule_action    = lookup(each.value.rule, "rule_action", "allow")
  cidr_block     = lookup(each.value.rule, "cidr_block", "0.0.0.0/0")
  from_port      = lookup(each.value.rule, "from_port", 0)
  to_port        = lookup(each.value.rule, "to_port", 0)
  egress         = true
  provider       = aws.test

  depends_on = [aws_network_acl.public]
}

# --- Dynamically create NACL rules for Private Subnets ---
resource "aws_network_acl_rule" "private_ingress" {
  for_each = {
    for idx, rule_data in local.private_ingress_rules : 
    "${rule_data.nacl_name}_ingress_${idx}" => rule_data
  }
  # network_acl_id = aws_network_acl.private[lookup(var.subnet_to_nacl_mapping, each.value.subnet_name)].id
  #network_acl_id = aws_network_acl.private[index(aws_network_acl.private[*].tags.Name, each.value.nacl_name)].id
  network_acl_id = lookup(
  { for nacl in aws_network_acl.private : nacl.tags.Name => nacl.id },
  each.value.nacl_name,
  null
)
  rule_number    = lookup(each.value.rule, "rule_number", 100) 
  protocol       = lookup(each.value.rule, "protocol", "tcp")
  rule_action    = lookup(each.value.rule, "rule_action", "allow")
  cidr_block     = lookup(each.value.rule, "cidr_block", "0.0.0.0/0")
  from_port      = lookup(each.value.rule, "from_port", 0)
  to_port        = lookup(each.value.rule, "to_port", 0)
  egress         = false
  provider       = aws.test

  depends_on = [aws_network_acl.private]
}

resource "aws_network_acl_rule" "private_egress" {
  for_each = {
    for idx, rule_data in local.private_egress_rules : 
    "${rule_data.nacl_name}_egress_${idx}" => rule_data
  }
  # network_acl_id = aws_network_acl.private[lookup(var.subnet_to_nacl_mapping, each.value.subnet_name)].id
  #network_acl_id = aws_network_acl.private[index(aws_network_acl.private[*].tags.Name, each.value.nacl_name)].id
  network_acl_id = lookup(
  { for nacl in aws_network_acl.private : nacl.tags.Name => nacl.id },
  each.value.nacl_name,
  null
)
  rule_number    = lookup(each.value.rule, "rule_number", 100) 
  protocol       = lookup(each.value.rule, "protocol", "tcp")
  rule_action    = lookup(each.value.rule, "rule_action", "allow")
  cidr_block     = lookup(each.value.rule, "cidr_block", "0.0.0.0/0")
  from_port      = lookup(each.value.rule, "from_port", 0)
  to_port        = lookup(each.value.rule, "to_port", 0)
  egress         = true
  provider       = aws.test

  depends_on = [aws_network_acl.private]
}


################### vpc flow logs ##################################

resource "aws_flow_log" "vpc_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs_grp.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  provider                = aws.test
  
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs_grp" {
  name = var.logs_grp
  provider  = aws.test
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = var.vpc_logs_iam_role
  provider = aws.test
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy" "vpc_logs_policy" {
  name = var.vpc_logs_policy
  provider= aws.test
  role = aws_iam_role.vpc_flow_logs.id
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
  lifecycle {
    prevent_destroy = false
  }
}