locals {
  security_group_name = "${var.name}-ecs-fargate"
  iam_name                   = "${var.name}-ecs-task-execution"
  enabled_ecs_task_execution = var.enabled ? 1 : 0 && var.create_ecs_task_execution_role ? 1 : 0
}

resource "aws_ecs_service" "default" {
  count = var.enabled ? 1 : 0
  name = var.name
  task_definition = aws_ecs_task_definition.default[0].arn
  desired_count = var.desired_count
  platform_version = var.platform_version
  launch_type = "FARGATE"

  deployment_controller {
    type = var.deployment_controller_type
  }

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.default[0].id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name = var.container_name
    container_port = var.container_port
  }

  resource "aws_security_group" "default" {
  count = var.enabled ? 1 : 0

  name   = local.security_group_name
  vpc_id = var.vpc_id
  tags   = merge({ "Name" = local.security_group_name }, var.tags)
}

resource "aws_security_group_rule" "ingress" {
  count = var.enabled ? 1 : 0

  type              = "ingress"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr_blocks
  security_group_id = aws_security_group.default[0].id
}

resource "aws_security_group_rule" "egress" {
  count = var.enabled ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default[0].id
}
resource "aws_ecs_task_definition" "default" {
  count = var.enabled ? 1 : 0
  family = var.name
  execution_role_arn = var.create_ecs_task_execution_role ? join("", aws_iam_role.default.*.arn) : var.ecs_task_execution_role_arn
  container_definitions = jsonencode([{
    name      = "keycloak"
    image     = var.image
    portMappings = [{
      containerPort = var.port,
      hostPort      = 0,
      protocol      = "tcp"
    }]
  }])

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
tags = merge({ "Name" = var.name }, var.tags)
} 

resource "aws_iam_role" "default" {
  count = local.enabled_ecs_task_execution

  name               = local.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = var.iam_path
  description        = var.description
  tags               = merge({ "Name" = local.iam_name }, var.tags)
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_policy" "default" {
  count = local.enabled_ecs_task_execution

  name        = local.iam_name
  policy      = data.aws_iam_policy.ecs_task_execution.policy
  path        = var.iam_path
  description = var.description
}

resource "aws_iam_role_policy_attachment" "default" {
  count = local.enabled_ecs_task_execution

  role       = aws_iam_role.default[0].name
  policy_arn = aws_iam_policy.default[0].arn
}


data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
