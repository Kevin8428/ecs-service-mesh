output "ecs_cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "autoscale_group_arn" {
  value = aws_autoscaling_group.group.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.logs.name
}

output "service_discovery_dns_arn" {
  value = aws_service_discovery_private_dns_namespace.dev_dns.arn
}

output "service_discovery_dns_name" {
  value = aws_service_discovery_private_dns_namespace.dev_dns.name
}

output "service_discovery_dns_id" {
  value = aws_service_discovery_private_dns_namespace.dev_dns.id
}

# output "aws_service_discovery_service_arn" {
#   value = aws_service_discovery_service.dev_dns.arn
# }