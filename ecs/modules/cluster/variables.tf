terraform {
  # bump tf version
  required_version = ">= 0.8"
}

# REQUIRED

variable "ecs_cluster_name" {
  type        = string
  description = "cluster name"
}

variable "app_name" {
  type        = string
  description = "app name"
}

variable "ami_image_id" {
  type        = string
  description = "ec2 image indentifier"
}

variable "ec2_instance_type" {
  type        = string
  description = "instance type"
}

variable "ec2_instance_key_name" {
  type        = string
  description = "Key for ec2 instances"
}

variable "autoscaling_group_name" {
  type        = string
  description = "autoscaling name"
}

variable "autoscale_security_group_ids" {
  type        = list(string)
  description = "Security groups attached to ec2 instances"
}

variable "autoscale_vpc_subnet_ids" {
  type        = list(string)
  description = "VPC subnets"
}

# OPTIONAL

variable "availability_zones" {
  type        = list(string)
  description = "AZs for EC2 instances"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Attach a public ip to the instance from within the VPC"
  default     = "false"
}

variable "autoscaling_min_size" {
  type        = number
  description = "min instance count"
  default     = 3
}

variable "autoscaling_max_size" {
  type        = number
  description = "max instance count"
  default     = 3
}

variable "autoscaling_desired_size" {
  type        = number
  description = "desired instance count"
  default     = 3
}

variable "init_script" {
  type        = string
  description = "bash script to bootstrap instance"
  default     = ""
}

variable "tags" {
  type = map(any)

  default = {}
}

locals {
  tags = merge(
    var.tags,
    {
      system = var.ecs_cluster_name
    }
  )
}
