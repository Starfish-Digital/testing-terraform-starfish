terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

#---- Cluster ----
# resource "aws_ecs_cluster" "this" {
#   name = element(var.cluster_names , count.index)
# }

resource "aws_ecs_cluster" "this" {
  count = length(var.cluster_names)
  name  = var.cluster_names[count.index]
  provider    = aws.test
  tags       = var.tags
}
