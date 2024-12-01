data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

resource "aws_codebuild_project" "this" {
  name                   = var.project_name
  description            = var.project_description
  badge_enabled          = true
  build_timeout          = var.build_timeout
  concurrent_build_limit = var.build_concurrent_limit
  queued_timeout         = var.build_queue_timeout
  service_role           = aws_iam_role.this.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    compute_type                = var.environment_compute_type
    image                       = var.environment_image
    type                        = var.environment_type
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false

  }

  logs_config {
    cloudwatch_logs {
      status     = var.logs_cloudwatch_enabled
      group_name = "/aws/codebuild/${var.project_name}"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.repository_url
    git_clone_depth = 1
  }

  tags = {
    Module = "GitHub-Actions-Runner"
  }
}

resource "aws_codebuild_webhook" "this" {
  project_name = var.project_name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "codebuild-${var.project_name}-service-role"
  description        = "Role for the ${var.project_name} build via the AWS CodeBuild service"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "CloudWatchLogs"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}",
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}:log-stream:*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "CodeBuild"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/*"
        ]
      },
    ]
  })
}