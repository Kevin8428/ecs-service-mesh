variable "db_name" {
  type        = string
  description = "db name"
}

variable "engine" {
  type        = string
  description = "db engine"
}

variable "engine_version" {
  type        = string
  description = "db engine version"
}

variable "instance_class" {
  type        = string
  description = "db instance class"
}

variable "username" {
  type        = string
  description = "connection username"
}

variable "password" {
  type        = string
  description = "connection password"
}

variable "parameter_group_name" {
  type        = string
  description = "name of the DB parameter group to associate"
}

variable "allocated_storage" {
  type        = number
  description = "GB of storage"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "determines whether a final DB snapshot is created before the DB instance is deleted"
}

