terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  project_name = "devops-challange"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "${project_name}-vpc"
  cidr_block           = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}

module "rds" {
  source = "./modules/rds"

  db_name                    = "${project_name}-db"
  db_username                = "${project_name}-user"
  db_password                = "${project_name}-password"
  db_instance_class          = "db.t3.micro"
  db_engine                  = "postgres"
  db_engine_version          = "11.5"
  db_allocated_storage       = 10
  db_subnet_group_name       = "${project_name}-subnet-group"
  db_parameter_group_name    = "${project_name}-parameter-group"
  db_multi_az                = true
  db_backup_retention_period = 7
  db_port                    = 5432
  db_security_groups         = ["sg-1234567890"]
  db_tags = {
    Name        = "keycloak-db"
    Environment = "dev"
  }
}
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ecs/cluster/${module.label.id}"
  retention_in_days = var.log_retention_days
  tags              = module.label.tags
}

resource "aws_ecs_cluster" "keycloak" {
  name = module.label.id
  tags = module.label.tags

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "keycloak-repo"
  tags = {
    Name        = "keycloak-repo"
    Environment = "dev"
  }
}

module "alb" {
  source = "./modules/alb"

  alb_name          = "keycloak-alb"
  listener_port     = 80
  target_group_name = "keycloak-target-group"
  target_group_port = 8080
  vpc_id            = "vpc-1234567890"
  subnet_ids        = ["subnet-1234567890", "subnet-0987654321"]
  security_groups   = ["sg-1234567890"]
  tags = {
    Name        = "keycloak-alb"
    Environment = "dev"
  }
}
resource "aws_route53_record" "alb" {
  zone_id = var.dns_zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = false
  }
}
module "postgres_secrets_manager" {
  source      = "./modules/secrets"
  secret_name = "postgres-credentials"
  db_username = "keycloak"
  db_password = "ajnapassword"
  tags = {
    Environment = "dev"
  }
}
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.logs"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "s3" {
  count           = var.internal ? 1 : 0
  auto_accept     = true
  route_table_ids = var.route_table_ids
  service_name    = "com.amazonaws.${var.region}.s3"
  tags            = module.label.tags
  vpc_id          = var.vpc_id
}

resource "aws_vpc_endpoint" "ssm" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.ssm"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ssm_messages" {
  count               = var.internal ? 1 : 0
  auto_accept         = true
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = var.private_subnet_ids
  tags                = module.label.tags
  vpc_endpoint_type   = "Interface"
  vpc_id              = var.vpc_id
}
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints"
  description = "Allow traffic for PrivateLink endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description     = "TLS from VPC"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.ecs.service_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = module.label.tags
}
module "keycloak_fargate" {
  source = "./path/to/module"

  name                 = "keycloak"
  image                = "jboss/keycloak:14.0.0"
  port                 = 8080
  subnets              = ["subnet-1234567890", "subnet-0987654321"]
  security_groups      = ["sg-1234567890"]
  alb_target_group_arn = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-target-group/1234567890"
  alb_listener_arn     = "arn:aws:elasticloadbalancing:us-west-2:123456789012:listener/my-listener/1234567890"
  desired_count        = 1
}


