output "docdb_cluster_id" {
  description = "The ID of the DocumentDB cluster"
  value       = aws_docdb_cluster.this.id
}

output "docdb_cluster_endpoint" {
  description = "The endpoint of the DocumentDB cluster"
  value       = aws_docdb_cluster.this.endpoint
}

output "docdb_cluster_reader_endpoint" {
  description = "The reader endpoint of the DocumentDB cluster"
  value       = aws_docdb_cluster.this.reader_endpoint
}

output "docdb_instances" {
  description = "The identifiers of the DocumentDB instances"
  value       = aws_docdb_cluster_instance.this[*].id
 
  }

output "sanitized_subnet_group_name" {
  description = "Sanitized name of the DocumentDB subnet group"
  value       = trimspace(var.subnet_group_name)
}

output "sanitized_subnet_ids" {
  description = "Sanitized list of subnet IDs for the DocumentDB subnet group"
  value       = [for id in var.subnet_ids : trimspace(id)]
}
