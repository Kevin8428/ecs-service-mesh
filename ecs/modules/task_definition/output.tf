output task_definition {
    value = aws_ecs_task_definition.task
}

output port_name {
    value = local.port_mapping_name
}

output host_port {
    value = var.host_port
}