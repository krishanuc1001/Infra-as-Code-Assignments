output "ecr_url" {
  description = "The Elastic Container Registry (ECR) URL."
  value       = aws_ecr_repository.api.repository_url
}

output "ecs_security_group_id" {
  description = "ECS Security group Id"
  value       = aws_security_group.ecs.id
}