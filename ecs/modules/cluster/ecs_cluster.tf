resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
}
resource "aws_ecs_account_setting_default" "insights" {
  name  = "containerInsights"
  value = "disabled"
}

# increase max ENI with trunking. Otherwise, can be throttled on task placement.
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/eni-trunking-supported-instance-types.html
resource "aws_ecs_account_setting_default" "trunking" {
  name  = "awsvpcTrunking"
  value = "enabled"
}

# TODO: move service discovery to own module
resource "aws_service_discovery_private_dns_namespace" "dev_dns" {
  name        = "development_dns"
  description = "example"
  vpc         = var.vpc.id
}

# pass this to service_registries
resource "aws_service_discovery_service" "dev_dns" {
  name = "development_discovery_service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.dev_dns.id

    dns_records {
      ttl  = 10
      type = "A" # TODO: use DNS to get Route 53 record instanceid.service.namespace
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}