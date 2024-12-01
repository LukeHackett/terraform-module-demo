variable "project_name" {
  description = "The name of the build project (must be unique within your account)"
  type        = string
  validation {
    condition     = can(regex("^[\\w-]+$", var.project_name))
    error_message = "Project Name must only contain letters, numbers underscores and dashes."
  }
}

variable "project_description" {
  description = "A description that makes the build project easy to identify"
  type        = string
  validation {
    condition     = length(var.project_description) > 4
    error_message = "Project Description is a required property."
  }
}

variable "repository_url" {
  description = "Github repository url"
  type        = string
  validation {
    condition     = startswith(var.repository_url, "https://github.com")
    error_message = "Project Name must only contain letters, numbers underscores and dashes."
  }
}

variable "build_concurrent_limit" {
  description = "The maximum number of concurrent builds that are allowed for this project"
  type        = number
  default     = 10
  validation {
    condition     = var.build_concurrent_limit >= 1
    error_message = "Project build concurrent limit must be greater than or equal to 1."
  }
}

variable "build_timeout" {
  description = "The number of minutes a build can run for before it times out"
  type        = number
  default     = 60
  validation {
    condition     = var.build_timeout >= 5
    error_message = "Project build timeout must be greater than or equal to 5 minutes."
  }
}

variable "build_queue_timeout" {
  description = "The number of minutes a build is allowed to be queued before it times out"
  type        = number
  default     = 60
  validation {
    condition     = var.build_queue_timeout >= 10
    error_message = "Project build timeout must be greater than or equal to 10 minutes."
  }
}

variable "environment_compute_type" {
  description = "The AWS CodeBuild on-demand environment type to use."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "environment_image" {
  description = "The AWS CodeBuild managed docker images to use."
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "environment_type" {
  description = "The type of environment to configure."
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "logs_cloudwatch_enabled" {
  description = "Whether to enable AWS CloudWatch Logs (this does not show/hide build logs)."
  type        = string
  default     = "DISABLED"
}

