variable "cpu" {
  type        = number
  default     = 80
  description = "container cpu"
}

variable "memory" {
  type        = number
  default     = 512
  description = "container memory"
}

variable "container_port" {
  type        = number
  description = "container port"
}

variable "host_port" {
  type        = number
  description = "host port"
}

variable "container_name" {
  type        = string
  description = "container name"
}

variable "queue_arn" {
  type        = string
  description = "queue arn"
  default = ""
}

variable "container_image" {
  type        = string
  description = "container image"
}

variable "availability_zones" {
  type        = list(any)
  description = "AZs required for placement"
}

variable "log_group_name" {
  type        = string
  description = "log group"
}

variable "name" {
  type        = string
  description = "task definition name"
}

variable "environment_variables" {
  type    = list(any)
  default = []
}

variable "tags" {
  type = map(any)
}
