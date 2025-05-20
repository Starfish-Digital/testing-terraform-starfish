terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_docdb_subnet_group" "this" {
  name       = trimspace(var.subnet_group_name)
  subnet_ids = [for id in var.subnet_ids : trimspace(id)]
  provider   = aws.test
  tags       = var.tags
}



resource "aws_docdb_cluster" "this" {
  cluster_identifier      = var.cluster_identifier
  master_username         = var.master_username
  master_password         = var.master_password
  engine_version          = var.engine_version
  db_subnet_group_name    = aws_docdb_subnet_group.this.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  storage_encrypted       = var.storage_encrypted
  apply_immediately       = var.apply_immediately
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  # final_snapshot_identifier = var.final_snapshot_identifier
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = true
  tags = var.tags
  provider = aws.test
}

resource "aws_docdb_cluster_instance" "this" {
  count                = var.instance_count
  identifier           = "${var.cluster_identifier}-${count.index}"
  cluster_identifier   = aws_docdb_cluster.this.id
  instance_class       = var.instance_class
  apply_immediately    = var.apply_immediately
  provider = aws.test
  tags = var.tags
}

