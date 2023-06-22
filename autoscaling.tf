#Launch template creation
resource "aws_launch_template" "web_lt" {
  name                   = "web-asg-lt"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "web_server"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }
  tags = {
    Name = "${var.project_name}-${var.env_name}-web-asg-LT"
  }
}

#Auto scaling group creation
resource "aws_autoscaling_group" "web_asg" {
  name             = "web-asg"
  min_size         = 1
  max_size         = 4
  desired_capacity = 2
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
  health_check_type    = "ELB"
  target_group_arns    = [aws_lb_target_group.web_tg.arn]
  vpc_zone_identifier  = aws_subnet.public_subnet[*].id
  termination_policies = ["OldestInstance"]
}

#ASG policy creation
resource "aws_autoscaling_policy" "web_asg_policy" {
  name                   = "web-asg-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"
  enabled                = true
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}