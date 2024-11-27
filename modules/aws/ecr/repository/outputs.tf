output "ecr_repository_arn" {
  description = "The ARN of the ECR Repository"
  value       = aws_ecr_repository.this.arn
}

output "ecr_repository_url" {
  description = "The URL of the ECR Repository"
  value       = aws_ecr_repository.this.repository_url
}
