

# Create an Application Load Balancer
resource "aws_lb" "capstone_load_balancer" {
  name               = "capstone-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.capstone_load_balancer_sg.id]
  subnets            = [aws_subnet.capstone_public_subnet1.id, aws_subnet.capstone_public_subnet2.id]
  #enable_cross_zone_load_balancing = true
  enable_deletion_protection = false
  depends_on                 = [aws_instance.server_1, aws_instance.server_2]
}

# Create the target group
resource "aws_lb_target_group" "capstone_target_group" {
  name        = "capstone-target-group"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.capstone_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create the listener
resource "aws_lb_listener" "capstone_listener" {

  load_balancer_arn = aws_lb.capstone_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.capstone_lb_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.capstone_target_group.arn
  }
}
# Create the listener rule
resource "aws_lb_listener_rule" "capstone_listener_rule" {
  listener_arn = aws_lb_listener.capstone_listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.capstone_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Attach the target group to the load balancer
resource "aws_lb_target_group_attachment" "capstone_target_group_attachment1" {
  target_group_arn = aws_lb_target_group.capstone_target_group.arn
  target_id        = aws_instance.server_1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "capstone_target_group_attachment2" {
  target_group_arn = aws_lb_target_group.capstone_target_group.arn
  target_id        = aws_instance.server_2.id
  port             = 80
}
