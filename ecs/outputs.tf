output "alb_dns_name" {
  value       = aws_lb.receipt_corrector.dns_name
  description = "The DNS name of the load balancer — use this to reach your app."
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.receipt_corrector.name
  description = "ECS cluster name — needed for GitHub Actions deployment step."
}

output "ecs_service_name" {
  value       = aws_ecs_service.receipt_corrector.name
  description = "ECS service name — needed for GitHub Actions deployment step."
}

output "ecs_task_definition_family" {
  value       = aws_ecs_task_definition.receipt_corrector.family
  description = "Task definition family — needed for GitHub Actions deployment step."
}

output "app_url" {
  value       = "http://ecs-corrector.${var.domain_name}"
  description = "Application URL"
}