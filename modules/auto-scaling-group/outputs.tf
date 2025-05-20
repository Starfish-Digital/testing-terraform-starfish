output "asg_names" {
  value = { for k, asg in aws_autoscaling_group.this : k => asg.name }
}
