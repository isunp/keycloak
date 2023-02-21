variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}
variable "image_name" {
  description = "Name of Docker image"
  type        = string
}

variable "source_path" {
  description = "Path to Docker image source"
  type        = string
}

variable "repository_name" {
  type        = string
  description = "repsitory name"
}

variable "tag" {
  description = "Tag to use for deployed Docker image"
  type        = string
  default     = "latest"
}
variable "push_script" {
  description = "Path to script to build and push Docker image"
  type        = string
  default     = ""
}

