# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

# Map subnet name to subnet ID
output "subnet_name_to_id" {
  value = {
    for subnet in aws_subnet.private : subnet.tags["Name"] => subnet.id
  }
}

output "private_subnet_map" {
  value = {
    for subnet in aws_subnet.private : subnet.tags["Name"] => subnet.id
  }
}