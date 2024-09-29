output "ecs_cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "autoscale_group_arn" {
  value = aws_autoscaling_group.group.arn
}
