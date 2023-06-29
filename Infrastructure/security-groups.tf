
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
