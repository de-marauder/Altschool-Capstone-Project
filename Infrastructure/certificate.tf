
resource "aws_acm_certificate" "capstone_lb_certificate" {
  domain_name       = "app.de-marauder.me"
  validation_method = "DNS"
  tags = {
    "Name" = "load-balancer certificate"
  }
}
