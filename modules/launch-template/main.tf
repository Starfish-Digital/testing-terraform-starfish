terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }

  required_version = ">= 1.1.7"
}

resource "aws_launch_template" "this" {
  for_each = {
    for lt in var.launch_templates : lt.name => lt
  }
  vpc_security_group_ids = var.vpc_security_group_ids
  name   = each.value.name
  image_id      = each.value.ami_id
  description = each.value.description
  instance_type = each.value.instance_type
  key_name      = each.value.key_name
  provider      = aws.test
  tags          = each.value.tags
  disable_api_stop        = each.value.disable_api_stop
  disable_api_termination = each.value.disable_api_termination
  user_data = base64encode(each.value.user_data)

  metadata_options {
    http_tokens   = each.value.metadata_options.http_tokens
  }

  iam_instance_profile {
     name = each.value.iam_instance_profile_name
  }

# Tag specifications for EC2 instance
tag_specifications {
  resource_type = "instance"

  tags = merge(
    {
      Name = "${each.value.instance_tag}-instance"
    },
    each.value.tags
  )
}

# Tag specifications for EBS volume
tag_specifications {
  resource_type = "volume"

  tags = merge(
    {
      Name = "${each.value.volume_tag}-volume"
    },
    each.value.tags
  )
}

}
