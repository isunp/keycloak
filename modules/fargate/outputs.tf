output "fargate_service_name" {
  value = aws_ecs_service.fargate_service.name
}

output "fargate_service_arn" {
  value = aws_ecs_service.fargate_service.arn
}
