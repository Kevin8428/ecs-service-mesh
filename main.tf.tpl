provider "aws" { region = "us-west-2" }
data "aws_caller_identity" "current" {}

locals {
  system_id         = "ecs-poc"
  region            = "us-west-2"
  api_tag           = "0.2.6"
  worker_tag        = "0.1.26"
  availability_zone = "us-west-2a"
  ecs_key           = __EC2_KEY_NAME__
  api_ecr_image    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/${local.system_id}-api:${local.api_tag}"
  worker_ecr_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/${local.system_id}-worker:${local.worker_tag}"
  # TODO: add tags everywhere
  tags = {
    Env      = "dev"
    SystemId = local.system_id
    Name     = local.system_id
  }
}

resource "aws_vpc" "main" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
  tags                             = local.tags
}


locals {
  vpc = { for k, v in aws_vpc.main : k => v if !contains(["tags_all", "tags"], k) }
}

# TODO: version tf modules
module "ecr_api" {
  source = "./ecr"
  name   = "${local.system_id}-api"
  tags   = local.tags
}

module "ecr_worker" {
  source = "./ecr"
  name   = "${local.system_id}-worker"
  tags   = local.tags
}

module "sns" {
  source = "./sns/modules"
  name   = "eventbus"
}

module "sqs" {
  source  = "./sqs/modules"
  name    = "ecs-consumer-2"
  sns_arn = module.sns.arn
}

module "gateways" {
  source = "./vpc/modules/internet_gateway"
  vpc    = local.vpc
  tags   = local.tags
}

module "private_subnet_1" {
  source            = "./vpc/modules/subnets/private"
  availability_zone = local.availability_zone
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1)
  nat_gateway_id    = module.public_subnet_1.nat_gateway_id
  vpc               = local.vpc
  tags              = local.tags
}

module "public_subnet_1" {
  source            = "./vpc/modules/subnets/public"
  availability_zone = local.availability_zone
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 2)
  ipv6_cidr_block   = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 2)
  internet_gateway  = module.gateways.internet_gateway
  vpc               = local.vpc
  tags              = local.tags
}

module "security_group_1" {
  source = "./security_group/modules"
  vpc    = local.vpc
}

module "cluster" {
  source                       = "./ecs/modules/cluster"
  ecs_cluster_name             = local.system_id
  autoscaling_min_size         = 3
  autoscaling_max_size         = 3
  autoscaling_desired_size     = 3
  vpc                          = local.vpc
  ec2_launch_template_name     = local.system_id
  ec2_instance_type            = "t3.small"
  ec2_instance_key_name        = local.ecs_key
  autoscale_security_group_ids = [module.security_group_1.security_group.id]
  subnet                       = module.private_subnet_1.subnet_id # run app in private subnet only
}

module "task_1" { # api
  source             = "./ecs/modules/task_definition"
  name               = "api"
  queue_arn          = module.sqs.arn
  availability_zones = [local.availability_zone]
  container_name     = "api"
  container_image    = local.api_ecr_image
  log_group_name     = module.cluster.log_group_name
  host_port          = 4000
  container_port     = 4000
  environment_variables = [
    {
      name  = "SECRET_ARN"
      value = "placeholder" # set when ready for api to query db
      # value = data.aws_secretsmanager_secret_version.rds_password.arn
    },
    {
      name  = "HOST_DNS"
      value = "placeholder" # set when ready for api to query db
    },
    {
      name  = "DATABASE_NAME"
      value = "placeholder" # set when ready for api to query db
    },
    {
      name  = "PORT"
      value = tostring(4000)
    }
  ]
  tags = local.tags
}

module "service_1" { # api
  source                 = "./ecs/modules/service"
  desired_count          = 2
  ecs_cluster_name       = module.cluster.ecs_cluster_name
  service_discovery_name = module.cluster.service_discovery_dns_name
  service_discovery_arn  = module.cluster.aws_service_discovery_service_arn
  port_name              = module.task_1.port_name
  vpc_id                 = local.vpc.id
  endpoint               = false
  subnet_ids = [
    module.private_subnet_1.subnet_id,
  ]
  ecs_service_name        = "api"
  ecs_task_definition_arn = module.task_1.task_definition.arn
  ecs_task_count          = 1
}

module "task_2" { # worker
  source             = "./ecs/modules/task_definition"
  name               = "worker"
  availability_zones = [local.availability_zone]
  container_name     = "worker"
  container_image    = local.worker_ecr_image
  log_group_name     = module.cluster.log_group_name
  host_port          = 5000
  container_port     = 5000
  environment_variables = [
    {
      name  = "QUEUE_NAME"
      value = module.sqs.name
    },
    {
      name  = "API_PORT"
      value = module.task_1.host_port
    },
    {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    },
    {
      name  = "AWS_REGION"
      value = "us-west-2"
    }
  ]
  tags = local.tags
}

module "service_2" {
  source                 = "./ecs/modules/service"
  desired_count          = 2
  ecs_cluster_name       = module.cluster.ecs_cluster_name
  port_name              = module.task_2.port_name
  service_discovery_name = module.cluster.service_discovery_dns_name
  service_discovery_arn  = module.cluster.aws_service_discovery_service_arn
  vpc_id                 = local.vpc.id
  endpoint               = true
  subnet_ids = [
    module.private_subnet_1.subnet_id,
  ]
  ecs_service_name        = "worker"
  ecs_task_definition_arn = module.task_2.task_definition.arn
  ecs_task_count          = 1
}

# rds is expensive - deploy when ready for UAT
# module "rds" {
#   source            = "./rds/modules/v1"
#   allocated_storage = 2
#   db_name           = "mydb"
#   engine            = "mysql"
#   engine_version    = "8.0"
#   instance_class    = "db.t3.micro"
#   username          = "foo"
#   password             = jsondecode(aws_secretsmanager_secret_version.rds_password.secret_string)["password"]
#   # password             = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)["password"]
#   parameter_group_name = "default.mysql8.0"
#   skip_final_snapshot  = true
# }

# deploy when ready for UAT
# resource "aws_secretsmanager_secret" "rds_v11" {
#   name = "rds_v11"
#   tags = local.tags
# }

# deploy when ready for UAT
# resource "aws_secretsmanager_secret_version" "rds_password" {
#   secret_id     = aws_secretsmanager_secret.rds_v11.id
#   secret_string = jsonencode({
#     "username": "<redacted>"
#     "password": "<redacted>"
#     })
# }

# data "aws_secretsmanager_secret_version" "rds_password" {
#   secret_id = aws_secretsmanager_secret.rds_v11.id
# }
