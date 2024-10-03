variable "vpc" {
  type        = map(any)
  description = "vpc object"
}

variable "tags" {
  type        = map(any)
  description = "tagging"
}

variable "availability_zone" {
  type        = string
  description = "subnet az"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for given sunet"
}

variable "ipv6_cidr_block" {
  type        = string
  description = "CIDR block for given sunet"
}

variable "internet_gateway" {
  type = object({
    arn      = string
    id       = string
    owner_id = string
    timeouts = optional(string, 100)
    vpc_id   = string
    tags = optional(object({
      Env      = optional(string)
      SystemId = optional(string)
      Name     = optional(string)
    }), {})
    tags_all = optional(object({
      Env      = optional(string)
      SystemId = optional(string)
      Name     = optional(string)
    }), {})
  })
  description = ""
}
