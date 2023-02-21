variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}
variable "db_allocated_storage" {
  type = number
}

variable "db_subnet_group_name" {
  type = string
}

variable "db_parameter_group_name" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "db_backup_retention_period" {
  type = number
}

variable "db_port" {
  type = number
}

variable "db_security_groups" {
  type = list(string)
}
