# REQUIRED

variable "ecs_cluster_name" {
  type        = string
  description = "cluster name"
}

variable "vpc" {
  type        = map
  description = "vpc object"
}

variable "ec2_launch_template_name" {
  type        = string
  description = "instance type"
}

variable "ec2_instance_type" {
  type        = string
  description = "instance type"
}

variable "ec2_instance_key_name" {
  type        = string
  description = "Key for ec2 instances"
}

variable "autoscale_security_group_ids" {
  type        = list(string)
  description = "Security groups attached to ec2 instances"
}

variable "subnet" {
  type        = string
  description = "VPC subnet id for ASG"
}

# OPTIONAL

variable "availability_zones" {
  type        = list(string)
  description = "AZs for EC2 instances"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# variable "associate_public_ip_address" {
#   type        = bool
#   description = "Attach a public ip to the instance from within the VPC"
#   default     = "false"
# }

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
