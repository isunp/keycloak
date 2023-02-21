variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
  default     = "keycloak"
}

variable "service_name" {
  type        = string
  description = "ECS service name"
  default     = "keycloak"
}

variable "task_family" {
  type        = string
  description = "ECS task family"
}

variable "target_group_arn" {
  type        = string
  description = "Load balancer target group arn"
}

variable "container_definitions" {
  type = list(object({
    name           = string
    image          = string
    cpu            = number
    memory         = number
    environment    = map(string)
    secrets        = map(string)
    container_port = number
  }))
  description = "List of container definition assigned to ecs task"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
  default     = null
}

variable "network_mode" {
  type        = string
  description = "ECS network mode"
  default     = "awsvpc"
}

variable "launch_type" {
  description = "ECS launch type"
  type = object({
    type   = string
    cpu    = number
    memory = number
  })
  default = {
    type   = "EC2"
    cpu    = null
    memory = null
  }
}
