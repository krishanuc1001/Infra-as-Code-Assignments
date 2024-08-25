output "ecr_url" {
  description = "The Elastic Container Registry (ECR) URL."
  value       = module.ecs.ecr_url
}

output "ecs_security_group_id" {
  description = "ECS Security group Id"
  value       = module.ecs.ecs_security_group_id
}

output "website_url" {
  description = "The website URL."
  value       = format("http://%s/users", aws_lb.lb.dns_name)
}