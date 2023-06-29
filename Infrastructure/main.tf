provider "aws" {
  region = var.region
}

# Save state_file in an S3 bucket
# terraform {
#   backend "s3" {
#     bucket         = "capstone-state-bucket"
#     key            = "terraform.tfstate"
#     region         = "eu-west-2"
#   }
# }

# Create a VPC
resource "aws_vpc" "capstone_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "capstoneVPC"
  }
}


# Create Public Subnet_1
resource "aws_subnet" "capstone_public_subnet1" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.av_zone1
  tags = {
    Name = "capstone_public_subnet1"
  }
}

# Create Public Subnet_2
resource "aws_subnet" "capstone_public_subnet2" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.av_zone2
  tags = {
    Name = "capstone_public_subnet2"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "capstone_igw" {
  vpc_id = aws_vpc.capstone_vpc.id

  tags = {
    Name = "capstoneInternetGateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "capstone_route_table_public" {
  vpc_id = aws_vpc.capstone_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstone_igw.id
  }
  tags = {
    Name = "capstone_route_table_public"
  }
}
resource "aws_route_table" "capstone_route_table_nat" {
  vpc_id = aws_vpc.capstone_vpc.id

  route {
    # cidr_block = var.vpc_cidr
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.database_nat_gateway.id
  }

  tags = {
    Name = "capstone-rtb-nat"
  }
}

# Associate public subnet 1 with public route table
resource "aws_route_table_association" "capstone_public_subnet1_association" {
  subnet_id      = aws_subnet.capstone_public_subnet1.id
  route_table_id = aws_route_table.capstone_route_table_public.id
}
# Associate public subnet 2 with public route table
resource "aws_route_table_association" "capstone_public_subnet2_association" {
  subnet_id      = aws_subnet.capstone_public_subnet2.id
  route_table_id = aws_route_table.capstone_route_table_public.id
}

# Associate private subnet with nat gateway via route table
resource "aws_route_table_association" "capstone-rtb-priv-assoc" {
  subnet_id      = aws_subnet.capstone_private_subnet.id
  route_table_id = aws_route_table.capstone_route_table_nat.id
}

# Create Network ACL
resource "aws_network_acl" "capstone_network_acl" {
  vpc_id     = aws_vpc.capstone_vpc.id
  subnet_ids = [aws_subnet.capstone_public_subnet1.id, aws_subnet.capstone_public_subnet2.id]
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# Create a private subnet
resource "aws_subnet" "capstone_private_subnet" {
  vpc_id            = aws_vpc.capstone_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.av_zone1

  tags = {
    Name = "capstone_private_Subnet"
  }
}

# Create a NAT gateway
resource "aws_nat_gateway" "database_nat_gateway" {
  allocation_id = aws_eip.database_eip.id
  subnet_id     = aws_subnet.capstone_public_subnet1.id
}

# Create Elastic IP
resource "aws_eip" "database_eip" {
  domain = "vpc"
}

# Create a security group for the load balancer
resource "aws_security_group" "capstone_load_balancer_sg" {
  name        = "capstone_load_balancer_sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.capstone_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    description = "HTTP"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    description = "HTTPS"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group to allow port 80, 443 and 2200
resource "aws_security_group" "capstone_security_grp_rule" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for instances"
  vpc_id      = aws_vpc.capstone_vpc.id
  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.capstone_load_balancer_sg.id]
  }
  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.capstone_load_balancer_sg.id]
  }
  ingress {
    description = "SSH"
    from_port   = 2200
    to_port     = 2200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
    description = "node-exporter"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9323
    to_port     = 9323
    description = "docker-metrics"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9324
    to_port     = 9324
    description = "cadvisor"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "capstone_security_grp_rule"
  }
}

# Create a security group for the bastion host
resource "aws_security_group" "bastion_security_group" {
  name        = "Bastion Security Group"
  description = "Security group for the bastion host"

  vpc_id = aws_vpc.capstone_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 2200
    to_port     = 2200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BastionSecurityGroup"
  }
}

# Create a security group for the Database instance
resource "aws_security_group" "database_security_group" {
  name        = "Database Security Group"
  description = "Security group for the database instance in a private subnet"
  vpc_id      = aws_vpc.capstone_vpc.id

  ingress {
    description     = "Allow SSH access from the bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.capstone_security_grp_rule.id]
  }
  ingress {
    description     = "Allow SSH access from the bastion host"
    from_port       = 2200
    to_port         = 2200
    protocol        = "tcp"
    security_groups = [aws_security_group.capstone_security_grp_rule.id]
  }
  ingress {
    description = "Allow incoming MongoDB traffic from the frontend instance"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.server_1.private_ip}/32", "${aws_instance.server_2.private_ip}/32"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
    description = "node-exporter"
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.monitoring_server.private_ip}/32"]
  }
  ingress {
    from_port   = 9323
    to_port     = 9323
    description = "docker-metrics"
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.monitoring_server.private_ip}/32"]
  }
  ingress {
    from_port   = 9324
    to_port     = 9324
    description = "cadvisor"
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.monitoring_server.private_ip}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic from the database instance"
  }
}

# Create a security group for the monitoring server

resource "aws_security_group" "monitoring_security_group" {
  name        = "monitoring_security_group"
  description = "Security group for monitoring server"
  vpc_id      = aws_vpc.capstone_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    description = "SSH"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    description = "HTTP"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3100
    to_port     = 3100
    description = "loki"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    description = "prometheus"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9093
    to_port     = 9093
    description = "alertmanager"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
    description = "node-exporter"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9323
    to_port     = 9323
    description = "docker-metrics"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9324
    to_port     = 9324
    description = "cadvisor"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#get ami id
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# create application server 1
resource "aws_instance" "server_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.keypair_filename
  vpc_security_group_ids = [aws_security_group.capstone_security_grp_rule.id]
  subnet_id              = aws_subnet.capstone_public_subnet1.id

  tags = {
    Name = "app_server_1"
  }
}

# create application server 2
resource "aws_instance" "server_2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.keypair_filename

  vpc_security_group_ids = [aws_security_group.capstone_security_grp_rule.id]
  subnet_id              = aws_subnet.capstone_public_subnet2.id

  tags = {
    Name = "app_server_2"
  }
}

# create database instance
resource "aws_instance" "database_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.keypair_filename

  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  subnet_id              = aws_subnet.capstone_private_subnet.id

  provisioner "remote-exec" {
    inline = [
      "sudo su -c 'echo Port 2200 >> /etc/ssh/sshd_config' && systemctl restart sshd.service"
    ]

    connection {
      type                = "ssh"
      bastion_host        = aws_instance.bastion_host.public_ip
      bastion_user        = "ubuntu"                            // Or the appropriate SSH user for the bastion host
      bastion_private_key = tls_private_key.rsa.private_key_pem // Path to the private key for the bastion host
      host                = self.private_ip
      user                = "ubuntu"                            // Or the appropriate SSH user for the private instance
      private_key         = tls_private_key.rsa.private_key_pem // Path to the private key for the private instance
      port                = 2200
    }
  }

  tags = {
    Name = "database_server"
  }
}

# create monitoring server
resource "aws_instance" "monitoring_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.montoring_instance_type
  key_name               = var.keypair_filename
  vpc_security_group_ids = [aws_security_group.monitoring_security_group.id]
  subnet_id              = aws_subnet.capstone_public_subnet1.id

  tags = {
    Name = "monitoring_server"
  }
}

# create bastion host

resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.keypair_filename

  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  subnet_id              = aws_subnet.capstone_public_subnet1.id

  provisioner "remote-exec" {
    inline = [
      "sudo su -c 'echo Port 2200 >> /etc/ssh/sshd_config' && systemctl restart sshd.service"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      port        = 2200
      user        = "ubuntu"                            // Or the appropriate SSH user for the private instance
      private_key = tls_private_key.rsa.private_key_pem // Path to the private key for the private instance
    }
  }

  tags = {
    Name = "bastion-host"
  }
}

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

# Create a file to store the IP addresses of the monitoring instance
resource "local_file" "monitoring_Ip" {
  filename = "${path.module}/inventories/monitoring"
  content  = <<EOT
${aws_instance.monitoring_server.public_ip}
  EOT
}

# Create a file to store the IP addresses of the application instances
resource "local_file" "application_Ip" {
  filename = "${path.module}/inventories/inventory"
  content  = <<EOT
${aws_instance.server_1.public_ip}
${aws_instance.server_2.public_ip}
  EOT
}

# Create a file to store the IP addresses of the bastion instance
resource "local_file" "bastion_Ip" {
  filename = "${path.module}/inventories/bastion"
  content  = <<EOT
${aws_instance.bastion_host.public_ip}
  EOT
}

# Create a file to store the IP addresses of the database instance
resource "local_file" "database_Ip" {
  filename = "${path.module}/inventories/database"
  content  = <<EOT
${aws_eip.database_eip.public_ip}
  EOT
}

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

resource "aws_acm_certificate" "capstone_lb_certificate" {
  domain_name       = "app.de-marauder.me"
  validation_method = "DNS"
  tags = {
    "Name" = "load-balancer certificate"
  }
}

# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.capstone_load_balancer.arn
#   port              = 443
#   protocol          = "HTTPS"

#   ssl_policy      = "ELBSecurityPolicy-2016-08"
#   certificate_arn = aws_acm_certificate.capstone_lb_certificate.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.capstone_target_group.arn
#   }
# }
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

##############################################################
##############################################################

resource "aws_key_pair" "altschool-keypair" {

  key_name   = var.keypair_filename
  public_key = tls_private_key.rsa.public_key_openssh

}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "altschool-keypair" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "../ansible/${var.keypair_filename}.pem"
  file_permission = 400
}

resource "local_file" "host_file" {
  content              = <<-EOT
---
all:
  children:
    servers:
      children:
        local:
          children:
            ubuntu:
              children:
                application:
                  hosts:
                    app-server-1:
                      ansible_host: ${aws_instance.server_1.public_ip}
                      ansible_user :  ubuntu
                      # private_key :  capstone-test-key.pem
                      # private_key :  ../Capstone_keypair.pem
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no'
                    app-server-2:
                      ansible_host: ${aws_instance.server_2.public_ip}
                      ansible_user :  ubuntu
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no'
                      # private_key :  ${var.keypair_filename}.pem
                      # private_key :  ../Capstone_keypair.pem
                database:
                  hosts:
                    db-server:
                      ansible_host: ${aws_instance.database_server.private_ip}
                      ansible_user :  ubuntu
                      ansible_port :  2200
                      # private_key :  ${var.keypair_filename}.pem
                      # private_key :  ../Capstone_keypair.pem
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ${var.keypair_filename}.pem ubuntu@18.130.83.54 -p 2200 -W %h:%p"'
                bastion:
                  hosts:
                    bastion-server:
                      ansible_host: ${aws_instance.bastion_host.public_ip}
                      ansible_user :  ubuntu
                      ansible_port: 2200
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no'
                      # private_key :  ${var.keypair_filename}.pem
                      # private_key :  Capstone_keypair.pem  

                monitoring:
                  hosts:
                    monitoring-server:
                      ansible_host: ${aws_instance.monitoring_server.public_ip}
                      ansible_user :  ubuntu
                      # private_key :  ${var.keypair_filename}.pem
                      # private_key :  Capstone_keypair.pem
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no'
EOT
  directory_permission = "0775"
  file_permission      = "0664"
  filename             = "./../ansible/inventories/production/servers.yml"
}
