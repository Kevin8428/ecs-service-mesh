variable "subnet_ids" {
  type        = list(any)
  description = ""
}

variable "port_name" {
  type        = string
  description = "from task definition. Needed to register via Service Connect"
}

variable "ecs_service_name" {
  type        = string
  description = ""
}

variable "vpc_id" {
  type        = string
  description = "for security group"
}

variable "ecs_cluster_name" {
  type        = string
  description = ""
}

variable "ecs_task_definition_arn" {
  type        = string
  description = ""
}

variable "ecs_task_count" {
  type        = number
  description = ""
}

variable "service_discovery_name" {
  type        = string
  description = "needed to register service in cloud map"
}

variable "service_discovery_arn" {
  type        = string
  description = "needed to register service in cloud map"
}

variable "endpoint" {
  type        = bool
  description = "flag to register vpc endpoint"
}

variable "desired_count" {
  type        = number
  description = "desired task count"
}

variable "tags" {
  type = map(any)

  default = {}
}