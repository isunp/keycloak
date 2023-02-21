variable "name" {
  description = "name of farget service"
}

variable "vpc_id" {
  description = "vpc id containing farget"
}

variable "subnet_ids" {
  description = "subnet id's"
}

variable "security_group_ids" {
  description = "sg for farget service"
}

variable "ecs_cluster_name" {
  description = "name of ecs cluster"
}

variable "ecs_task_definition_arn" {
  description = "task defination"
}

