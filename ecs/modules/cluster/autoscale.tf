data "aws_ami" "amazon-linux-2-ecs-optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-ecs*"]
  }
}

data "template_file" "init_script" {
  template = file("${path.module}/init_script.sh")

  vars = {
    ecs_cluster_name = var.ecs_cluster_name
    init_script      = var.init_script
  }
}

resource "aws_launch_template" "instance_manager" {
  name                   = var.ecs_cluster_name
  image_id               = data.aws_ami.amazon-linux-2-ecs-optimized.id
  instance_type          = var.ec2_instance_type
  update_default_version = true
  key_name               = var.ec2_instance_key_name

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 120
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = false # networking mode `awsvpc` won't let you attach public ip, need private subnet w/ nat gateway
    subnet_id                   = var.subnet
  }

  user_data = base64encode(data.template_file.init_script.rendered)
}

resource "aws_autoscaling_group" "group" {
  name                = var.ecs_cluster_name
  min_size            = var.autoscaling_min_size
  max_size            = var.autoscaling_max_size
  desired_capacity    = var.autoscaling_desired_size
  health_check_type   = "EC2"
  vpc_zone_identifier = [var.subnet]

  launch_template {
    id      = aws_launch_template.instance_manager.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

}
