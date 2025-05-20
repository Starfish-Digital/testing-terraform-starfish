output "launch_template_ids" {
  description = "Launch template IDs"
  value = {
    for k, lt in aws_launch_template.this : k => lt.id
  }
}
