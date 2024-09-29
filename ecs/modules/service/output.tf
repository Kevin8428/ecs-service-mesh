output "ecs_cluster_id" {
  value = "${aws_ecs_service.service_definition.id}"
}
