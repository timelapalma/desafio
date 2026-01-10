resource "aws_launch_template" "lab" {
  name_prefix   = "terraform-aws-asg-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"

  user_data = base64encode(file("templates/server.yaml"))

  vpc_security_group_ids = [aws_security_group.asg_lab.id]
  key_name               = "vockey"

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "lab" {
  name               = "lab"
  min_size           = 1
  max_size           = 1
  desired_capacity   = 1
  vpc_zone_identifier = module.vpc.public_subnets

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.lab.id
    version = "$Latest"
  }

  # liga o mesmo ASG nos 2 target groups
  target_group_arns = [
    aws_lb_target_group.server.arn,
    aws_lb_target_group.grafana.arn
  ]

  tag {
    key                 = "Name"
    value               = "server"
    propagate_at_launch = true
  }
}

### Application Server ALB

resource "aws_lb" "server" {
  name               = "asg-server-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg_lab_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "server" {
  load_balancer_arn = aws_lb.server.arn
  port              = 80
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

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

### Grafana ALB

resource "aws_lb" "grafana" {
  name               = "asg-grafana-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg_lab_lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_target_group" "grafana" {
  name     = "asg-grafana"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}