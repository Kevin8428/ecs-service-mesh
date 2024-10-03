##### make sure that the security group associated with the service has access from itself
resource "aws_cloudwatch_log_group" "service" {
  name = var.ecs_service_name
  tags = var.tags
}

resource "aws_ecs_service" "service_definition" {
  name                 = var.ecs_service_name
  cluster              = var.ecs_cluster_name
  task_definition      = var.ecs_task_definition_arn
  desired_count        = var.desired_count
  force_new_deployment = true

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  network_configuration {
    subnets = var.subnet_ids
    security_groups = [aws_security_group.sg.id]
    # assign_public_ip = false # TODO: update?
  }

  service_registries {
    registry_arn = var.service_discovery_arn
  }

  service_connect_configuration {
    enabled = true
    # all services in this namespace can talk to this service
    # and this service can talk to all them
    namespace = var.service_discovery_name

    service {
      # discovery name is registered in cloud map
      discovery_name = var.ecs_service_name
      # reference to container port
      port_name = var.port_name
      # timeout {
      #   per_request_timeout_seconds = 100
      # }
      # friendlier DNS name to call out service

      # this assigns the port number and DNS name
      client_alias {
        # can reach this service via dns_name:port
        dns_name = "${var.ecs_service_name}.${var.service_discovery_name}"
        # dns_name = var.ecs_service_name
        port     = 8000
      }
    
    }

    log_configuration {
      log_driver = "awslogs"
      options = {
        awslogs-group  = aws_cloudwatch_log_group.service.name
        awslogs-region = "us-west-2"
      }
    }
  }
}

resource "aws_security_group" "sg" {
  name        = var.ecs_service_name
  description = "Allow web traffic from anywhere for now" # TODO: restrict this
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# TODO: move this out of this module
resource "aws_security_group" "security_group_ie" {
  vpc_id = var.vpc_id
  ingress {
    description = "HTTPS for Endpoint Interface"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}