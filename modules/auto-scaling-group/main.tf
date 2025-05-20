terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_autoscaling_group" "this" {
  for_each = {
    for asg in var.auto_scaling_groups : asg.name => asg
  }

  name                      = each.value.name
  min_size                  = each.value.min_size
  max_size                  = each.value.max_size
  desired_capacity          = each.value.desired_capacity
  vpc_zone_identifier       = each.value.subnet_ids
  health_check_type         = each.value.health_check_type
  force_delete              = each.value.force_delete
  provider                  = aws.test

  launch_template {
    id      = each.value.launch_template_id
    version = "$Latest"
  }

  instance_maintenance_policy {
    min_healthy_percentage = each.value.min_healthy_percentage
    max_healthy_percentage = each.value.max_healthy_percentage
  }
  
  dynamic "tag" {
  for_each = merge(
    each.value.tags,
    {
      AmazonECSManaged = ""
    }
  )
  content {
    key                 = tag.key
    value               = tag.value
    propagate_at_launch = true
  }
}

}

resource "aws_autoscaling_lifecycle_hook" "this" {
  for_each = {
    for asg in var.auto_scaling_groups : asg.name => asg
    if contains(keys(asg), "lifecycle_hook") && asg.lifecycle_hook != null
  }

  name                    = each.value.lifecycle_hook.name
  autoscaling_group_name = aws_autoscaling_group.this[each.key].name
  lifecycle_transition   = each.value.lifecycle_hook.lifecycle_transition
  default_result         = each.value.lifecycle_hook.default_result
  heartbeat_timeout      = each.value.lifecycle_hook.heartbeat_timeout
  provider                = aws.test
}
