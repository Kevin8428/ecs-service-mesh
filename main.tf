# SECRET DATA

data "aws_kms_alias" "rds" {
  name = "alias/rds"
}

data "aws_secretsmanager_secret" "rds" {
  name = "rds"
}

# PROVIDERS

provider "aws" {
  region = "us-west-2"
}

# RESOURCES

module "subnet_1a" {
  source = "./vpc/modules/subnets/private"
  cidr_block = "172.31.0.0/17" # need to inject vpc
  availability_zone = "us-east-1a"
}

module "subnet_1b" {
  source = "./vpc/modules/subnets/private"
  cidr_block = "172.31.128.0/18" # need to inject vpc
  availability_zone = "us-east-1b"
}

module "subnet_1c" {
  source = "./vpc/modules/subnets/private"
  cidr_block = "172.31.192.0/18" # need to inject vpc
  availability_zone = "us-east-1c"
}

module "cluster" {
  source                       = "./ecs/modules/cluster"
  ecs_cluster_name             = "customers"
  autoscaling_min_size         = 3
  autoscaling_max_size         = 3
  autoscaling_desired_size     = 3
  app_name                     = ""
  ami_image_id                 = ""
  ec2_instance_type            = ""
  ec2_instance_key_name        = ""
  autoscaling_group_name       = ""
  autoscale_security_group_ids = ""
  autoscale_vpc_subnet_ids     = [subnet_1a.subnet_id,subnet_1b.subnet_id,subnet_1c.subnet_id]
  tags = {} # remove this, use defaults only
}
