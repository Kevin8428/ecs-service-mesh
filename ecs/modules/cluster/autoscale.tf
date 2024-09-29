data "template_file" "init_script" {
  template = file("${path.module}/init_script.sh")

  vars = {
    ecs_cluster_name = var.ecs_cluster_name
    init_script      = var.init_script
  }
}

resource "aws_launch_template" "instance_manager" {
  name                   = "foo"
  image_id               = var.ami_image_id
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

  network_interfaces {
    device_index                = 0
    subnet_id                   = data.aws_subnet.subnet.id
    associate_public_ip_address = true
    security_groups             = var.autoscale_security_group_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  user_data = filebase64("${path.module}/example.sh")

}


resource "aws_autoscaling_group" "group" {
  availability_zones  = var.availability_zones
  name                = var.autoscaling_group_name
  min_size            = var.autoscaling_min_size
  max_size            = var.autoscaling_max_size
  desired_capacity    = var.autoscaling_desired_size
  health_check_type   = "EC2"
  vpc_zone_identifier = var.autoscale_vpc_subnet_ids

  launch_template {
    id      = aws_launch_template.instance_manager.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

}
