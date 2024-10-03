variable "vpc" {
  type        = map
  description = "vpc object"
}

variable tags {
    type = map
    description = "tagging"
}

variable "availability_zone" {
  type        = string
  description = "subnet az"
}

variable "cidr_block" {
  type = string
  description = "CIDR block for given sunet"
}

variable "ipv6_cidr_block" {
  type = string
  description = "CIDR block for given sunet"
}

variable "nat_gateway_id" {
  type = string
  description = "forward from private subnet"
}
