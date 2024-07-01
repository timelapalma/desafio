resource "aws_launch_configuration" "lab" {
  name_prefix           = "terraform-aws-asg-"
  image_id              = data.aws_ami.ubuntu.id
  instance_type         = "t3.medium"
  user_data             = "${file("templates/server.yaml")}"
  security_groups       = [aws_security_group.asg_lab]
  key_name              = "vockey"
  iam_instance_profile  = "LabInstanceProfile"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "lab" {
  name                 = "lab"
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.lab.name
  vpc_zone_identifier  = module.vpc.public_subnets

  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "server"
    propagate_at_launch = true
  }  
}

resource "aws_lb" "server" {
  name               = "asg-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg_lab_lb]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "server" {
  load_balancer_arn = aws_lb.server.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}

resource "aws_lb_target_group" "server" {
  name     = "asg-server"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}


resource "aws_autoscaling_attachment" "server" {
  autoscaling_group_name = aws_autoscaling_group.lab.id
  alb_target_group_arn   = aws_lb_target_group.server.arn
}