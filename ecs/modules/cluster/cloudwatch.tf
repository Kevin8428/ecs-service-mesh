resource "aws_cloudwatch_log_group" "logs" {
  name = var.ecs_cluster_name

  tags = var.tags
}
