resource "aws_launch_configuration" "lab" {
  name_prefix     = "terraform-aws-asg-"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t3.medium"
  user_data       = "${file("templates/server.yaml")}"
  security_groups = [aws_security_group.lab_server.id]
  key_name        = "vockey"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "lab" {
  name                 = "lab"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.lab.name
  vpc_zone_identifier  = module.vpc.public_subnets

  health_check_type    = "ELB"

  tag {
    key                 = "application_id"
    value               = "1"
    propagate_at_launch = true
  }

  tag {
    key                 = "application_version"
    value               = "0.0.1"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "development"
    propagate_at_launch = true
  }

  tag {
    key                 = "role"
    value               = "application"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "application-server"
    propagate_at_launch = true
  }  
}

resource "aws_lb" "lab" {
  name               = "asg-lab-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lab_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "lab" {
  load_balancer_arn = aws_lb.lab.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab.arn
  }
}

resource "aws_lb_target_group" "lab" {
  name     = "asg-lab"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}


resource "aws_autoscaling_attachment" "lab" {
  autoscaling_group_name = aws_autoscaling_group.lab.id
  alb_target_group_arn   = aws_lb_target_group.lab.arn
}
