
# get hosted zone details
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
  tags = {
    Name = "capstone_hosted_zone"
  }
}

# create a record set for the load balancer
resource "aws_route53_record" "app_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "app.${var.domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.capstone_load_balancer.dns_name
    zone_id                = aws_lb.capstone_load_balancer.zone_id
    evaluate_target_health = true
  }
}

####################################################################################
# New stuff
####################################################################################

resource "aws_route53_record" "app_validation" {
  for_each = {
    for dvo in aws_acm_certificate.capstone_lb_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.hosted_zone.zone_id
}
resource "aws_acm_certificate_validation" "capstone" {
  certificate_arn         = aws_acm_certificate.capstone_lb_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.app_validation : record.fqdn]

}
resource "aws_lb_listener_certificate" "capstone_lb_certificate" {
  certificate_arn = aws_acm_certificate.capstone_lb_certificate.arn
  listener_arn    = aws_lb_listener.capstone_listener.arn
}

##############################################################
##############################################################

resource "aws_route53_record" "grafana_monitoring_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "grafana.monitoring.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring_server.public_ip]
}
resource "aws_route53_record" "prom_monitoring_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "prom.monitoring.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring_server.public_ip]
}
resource "aws_route53_record" "loki_monitoring_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "loki.monitoring.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring_server.public_ip]
}
resource "aws_route53_record" "alert_monitoring_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "alert.monitoring.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring_server.public_ip]
}
resource "aws_route53_record" "node_monitoring_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "node.monitoring.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring_server.public_ip]
}
resource "aws_route53_record" "docker_monitoring_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "docker.monitoring.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring_server.public_ip]
}
resource "aws_route53_record" "cadvisor_monitoring_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "cadvisor.monitoring.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring_server.public_ip]
}
##############################################################

resource "aws_route53_record" "node_app_1_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "node.app-1.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.server_1.public_ip]
}
resource "aws_route53_record" "docker_app_1_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "docker.app-1.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.server_1.public_ip]
}
resource "aws_route53_record" "cadvisor_app_1_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "cadvisor.app-1.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.server_1.public_ip]
}
##############################################################

resource "aws_route53_record" "node_app_2_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "node.app-2.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.server_2.public_ip]
}
resource "aws_route53_record" "docker_app_2_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "docker.app-2.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.server_2.public_ip]
}
resource "aws_route53_record" "cadvisor_app_2_record" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "cadvisor.app-2.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.server_2.public_ip]
}
