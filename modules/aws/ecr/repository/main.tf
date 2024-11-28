resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy = jsonencode(tolist([
    {
      "rulePriority" = 1
      "description"  = "Expire images older than 14 days"
      "selection" = {
        "tagStatus"   = "untagged"
        "countType"   = "sinceImagePushed"
        "countUnit"   = "days"
        "countNumber" = 14
      }
      "action" = {
        "type" = "expire"
      }
    }
  ]))
}

resource "aws_ecr_replication_configuration" "this" {
  # Only create the replication configuration if the replicated regions have been provided
  count = length(var.replicated_regions) > 0 ? 1 : 0

  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = var.replicated_regions
        content {
          region      = destination.key
          registry_id = data.aws_caller_identity.current.account_id
        }
      }

      repository_filter {
        filter      = aws_ecr_repository.this.name
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}
