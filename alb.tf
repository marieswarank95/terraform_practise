#ALB creation
/*resource "aws_lb" "web_lb" {
  name                       = "web-app-loadbalancer"
  internal                   = false
  load_balancer_type         = "application"
  ip_address_type            = "ipv4"
  subnets                    = aws_subnet.public_subnet[*].id
  security_groups            = [aws_security_group.web_server_sg.id]
  enable_deletion_protection = true
  tags = {
    Name = "${var.project_name}-${var.env_name}-load_balancer"
  }
}

# Target Group creation
resource "aws_lb_target_group" "web_tg" {
  name                          = "web-server-tg"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = aws_vpc.vpc.id
  deregistration_delay          = 60 #default 300 seconds
  load_balancing_algorithm_type = "round_robin"
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
    enabled         = true
  }
  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 30
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
  target_type = "instance"
}

#ALB listner creation
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

#Target group attachment
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count            = length(aws_instance.web_server[*].id)
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = element(aws_instance.web_server[*].id, count.index)
}
*/