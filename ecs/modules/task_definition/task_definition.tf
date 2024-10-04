locals {
  zones             = replace(jsonencode(var.availability_zones), "\"", "")
  expression        = "attribute:ecs.availability-zone in ${local.zones}"
  port_mapping_name = var.name
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.name
  execution_role_arn       = aws_iam_role.ecs_task.arn
  task_role_arn            = aws_iam_role.ecs_instance_role.arn
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  container_definitions = jsonencode([
    {
      name        = var.container_name
      image       = var.container_image
      cpu         = var.cpu
      memory      = var.memory
      essential   = true
      entryPoint  = var.entrypoint
      command     = var.command
      environment = var.environment_variables
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "ecs/${var.container_name}"
        }
      },
      portMappings = [
        {
          name          = local.port_mapping_name
          containerPort = var.container_port
          hostPort      = var.host_port
          # appProtocol   = "tcp"
        }
      ]
    }
  ])

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = local.expression
  # }

}
