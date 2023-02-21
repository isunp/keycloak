resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids
  tags       = var.db_tags
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  name   = var.db_parameter_group_name
  family = var.db_engine

  parameter {
    name  = "max_connections"
    value = "1000"
  }

  tags = var.db_tags
}
resource "aws_db_instance" "rds_instance" {
  identifier              = var.db_name
  allocated_storage       = var.db_allocated_storage
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name    = aws_db_parameter_group.rds_parameter_group.name
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  port                    = var.db_port
  vpc_security_group_ids  = var.db_security_groups
  tags                    = var.db_tags
}
