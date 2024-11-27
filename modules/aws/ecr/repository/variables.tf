data "aws_caller_identity" "current" {}

variable "name" {
  description = "Name of the Repository"
  type        = string
}

variable "tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "IMMUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.tag_mutability)
    error_message = "Allowed values for tag_mutability are \"MUTABLE\" or \"IMMUTABLE\". Defaults to \"IMMUTABLE\"."
  }
}

variable "replicated_regions" {
  description = "The tag mutability setting for the repository"
  type        = set(string)
  default     = []
}
