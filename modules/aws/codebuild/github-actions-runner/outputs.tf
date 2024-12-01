output "project_name" {
  description = "The name of the CodeBuild Project"
  value       = var.project_name
}

output "project_arn" {
  description = "The ARN of the CodeBuild Project"
  value       = aws_codebuild_project.this.arn
}

output "project_url" {
  description = "The location of the CodeBuild Project as a HTTPS URL"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/codesuite/codebuild/${data.aws_caller_identity.current.account_id}/${var.project_name}/history?region=${data.aws_region.current.name}"
}

output "project_role_name" {
  description = "The name of the IAM Role that the CodeBuild Project will execute as"
  value       = aws_iam_role.this.name
}

output "project_role_arn" {
  description = "The ARN of the IAM Role that the CodeBuild Project will execute as"
  value       = aws_iam_role.this.arn
}
