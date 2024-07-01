resource "aws_launch_configuration" "monitoring" {
  name_prefix     = "terraform-aws-asg-"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t3.medium"
  user_data       = "${file("templates/prometheus.yaml")}"
  security_groups = [aws_security_group.monitoring_server.id]
  key_name        = "vockey"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "monitoring" {
  name                 = "monitoring"
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.monitoring.name
  vpc_zone_identifier  = module.vpc.public_subnets

  health_check_type    = "ELB"

  tag {
    key                 = "env"
    value               = "development"
    propagate_at_launch = true
  }

  tag {
    key                 = "role"
    value               = "monitoring"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "monitoring-server"
    propagate_at_launch = true
  }  
}

resource "aws_lb" "monitoring" {
  name               = "asg-monitoring-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.monitoring_lb.id]
  subnets            = module.vpc.public_subnets
}

# --- Prometheus Target

resource "aws_lb_listener" "prometheus" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
}

resource "aws_lb_target_group" "prometheus" {
  name     = "asg-prometheus"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/-/healthy"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}


resource "aws_autoscaling_attachment" "prometheus" {
  autoscaling_group_name = aws_autoscaling_group.monitoring.id
  alb_target_group_arn   = aws_lb_target_group.prometheus.arn
}

# --- Grafana Target

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 3000
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
    path                = "/healthz"
    port                = 3000
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}


resource "aws_autoscaling_attachment" "prometheus" {
  autoscaling_group_name = aws_autoscaling_group.monitoring.id
  alb_target_group_arn   = aws_lb_target_group.grafana.arn
}
