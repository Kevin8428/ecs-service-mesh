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

# creates one Route Map namespace
# ECS services register via aws_ecs_service.service_registries
# and link their service via aws_service_discovery_service
# Now, each service gets a single Route 53 record in this resources `name`
# with their own records so can dig `service.namespace` or
# curl http://service.namespace:<route>/<path>
resource "aws_service_discovery_private_dns_namespace" "dev_dns" {
  name        = var.ecs_cluster_name
  description = "Make services related to ${var.ecs_cluster_name} discoverable via DNS"
  vpc         = var.vpc.id
}