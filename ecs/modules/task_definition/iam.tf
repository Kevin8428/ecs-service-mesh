data aws_caller_identity current {}
data aws_region current {}

data "aws_iam_policy" "amazon_ecs_task_execution_role_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "amazon_ec2_container_service_for_ec2_role" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

############### task role ###############

resource "aws_iam_role" "ecs_instance_role" {
  name                = "${var.container_name}-ecsInstanceRole"
  managed_policy_arns = [
    data.aws_iam_policy.amazon_ec2_container_service_for_ec2_role.arn,
    aws_iam_policy.ecs_tasks_ssm.arn
    ]
  assume_role_policy  = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_policy" "ecs_tasks_ssm" {
  name        = "${var.container_name}-ecsTasksSSM"
  description = "Access SSM in ECS task"
  policy      = data.aws_iam_policy_document.task_role_2.json
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    sid     = ""
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_role_2" {
  statement {
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "ssmmessages:*",
      "ssm:*"
    ]
  }
  statement {
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "sqs:*"
    ]
  }
  statement {
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "servicediscovery:*"
    ]
  }
}


############### execution role ###############

resource "aws_iam_role" "ecs_task" {
  name               = var.container_name
  tags               = var.tags
  managed_policy_arns = [
    data.aws_iam_policy.amazon_ecs_task_execution_role_policy.arn,
    aws_iam_policy.ecs_tasks_secrets.arn,
  ]
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_policy" "ecs_tasks_secrets" {
  name        = "${var.container_name}-ecsTasksSecrets"
  description = "Access Secrets in ECS Tasks"
  policy      = data.aws_iam_policy_document.ecs_tasks_secrets_policy.json
}

data "aws_iam_policy_document" "ecs_tasks_secrets_policy" {
  statement {
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "kms:Decrypt",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue"
    ]
  }
  statement {
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "sqs:*"
    ]
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = var.container_name
  description = "Permissions needed for the task"
  policy      = data.aws_iam_policy_document.ecs_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task.id
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

data aws_iam_policy_document ecs_policy_doc {
  statement {
    sid       = "ecrAllow"
    effect    = "Allow"
    actions   = [
      "ecr:*",
    ]
    resources =[ "*"]
  }
  
  statement {
    sid       = "logsAllow"
    effect    = "Allow"
    actions   = [
      "logs:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "SQSAllow"
    effect    = "Allow"
    actions   = [
      "sqs:*"
    ]
    resources = ["*"]
  }
}

# TODO: remove full access
# resource "aws_iam_role_policy_attachment" "ecs_attach_policy_3" {
#   role       = aws_iam_role.ecs_task.id
#   policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
# }

# resource "aws_iam_role_policy_attachment" "ecs_attach_policy_4" {
#   role       = aws_iam_role.ecs_task.id
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }