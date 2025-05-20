output "this_aws_ecs_cluster_names" {
  value = [for cluster in aws_ecs_cluster.this : cluster.name]
}

output "this_aws_ecs_cluster_arns" {
  value = [for cluster in aws_ecs_cluster.this : cluster.arn]
}
