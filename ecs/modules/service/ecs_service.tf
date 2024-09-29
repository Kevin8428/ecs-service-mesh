resource "aws_ecs_service" "service_definition" {
    name            = "${var.ecs_service_name == "" ? var.app_name : var.ecs_service_name}"
    cluster         = "${aws_ecs_cluster.cluster.id}"
    task_definition = "${var.ecs_task_definition_arn}"
    desired_count   = "${var.num_ecs_tasks == 0 ? length(var.availability_zones) : var.num_ecs_tasks}"
}