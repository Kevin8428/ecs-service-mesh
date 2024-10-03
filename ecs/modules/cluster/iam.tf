resource "aws_iam_role_policy_attachment" "ecs_container_registry" {
  role       = aws_iam_role.ecs_host_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# resource "aws_iam_role_policy_attachment" "ecs_attach_policy_2" {
#   role       = aws_iam_role.ecs_host_role.id
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
# }

# TODO: remove full access
resource "aws_iam_role_policy_attachment" "ecs_attach_policy_3" {
  role       = aws_iam_role.ecs_host_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
resource "aws_iam_role_policy_attachment" "ecs_attach_policy_4" {
  role       = aws_iam_role.ecs_host_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ecs" {
  name = var.ecs_cluster_name
  role = aws_iam_role.ecs_host_role.name
}

resource "aws_iam_role" "ecs_host_role" {
  name               = "${var.ecs_cluster_name}_ecs_host_role"
  path               = "/"
  assume_role_policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Action": "sts:AssumeRole",
             "Principal": {
                "Service": "ec2.amazonaws.com"
             },
             "Effect": "Allow",
             "Sid": ""
         }
     ]
 }
 EOF
}

output "ecs_instance_profile_role_id" { value = aws_iam_role.ecs_host_role.id }

