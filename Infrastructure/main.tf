provider "aws" {
  region = var.region
}

# Save state-file in an S3 bucket
terraform {
  backend "s3" {
    bucket         = "capstone-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
  }
}

# Create a VPC
resource "aws_vpc" "capstone_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "capstoneVPC"
  }
}


# Create Public Subnet-1
resource "aws_subnet" "capstone-public-subnet1" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.av-zone1
  tags = {
    Name = "capstone-public-subnet1"
  }
}

# Create Public Subnet-2
resource "aws_subnet" "capstone-public-subnet2" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.av-zone2
  tags = {
    Name = "capstone-public-subnet2"
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
resource "aws_route_table" "capstone-route-table-public" {
  vpc_id = aws_vpc.capstone_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstone_igw.id
  }
  tags = {
    Name = "capstone-route-table-public"
  }
}



# Create a private subnet
resource "aws_subnet" "capstone-private-subnet" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.av-zone1

  tags = {
    Name = "capstone-private-Subnet"
  }
}

# Associate public subnet 1 with public route table
resource "aws_route_table_association" "capstone-public-subnet1-association" {
  subnet_id      = aws_subnet.capstone-public-subnet1.id
  route_table_id = aws_route_table.capstone-route-table-public.id
}
# Associate public subnet 2 with public route table
resource "aws_route_table_association" "capstone-public-subnet2-association" {
  subnet_id      = aws_subnet.capstone-public-subnet2.id
  route_table_id = aws_route_table.capstone-route-table-public.id
}

# Create Network ACL
resource "aws_network_acl" "capstone-network_acl" {
  vpc_id     = aws_vpc.capstone_vpc.id
  subnet_ids = [aws_subnet.capstone-public-subnet1.id, aws_subnet.capstone-public-subnet2.id]
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

# Create a security group for the load balancer
resource "aws_security_group" "capstone-load_balancer_sg" {
  name        = "capstone-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.capstone_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
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
resource "aws_security_group" "capstone-security-grp-rule" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for instances"
  vpc_id      = aws_vpc.capstone_vpc.id
 ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.capstone-load_balancer_sg.id]
  }
 ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.capstone-load_balancer_sg.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "capstone-security-grp-rule"
  }
}

# Create a security group for the bastion host
resource "aws_security_group" "bastion_security_group" {
  name        = "Bastion Security Group"
  description = "Security group for the bastion host"

  vpc_id = aws_vpc.capstone_vpc.id

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

  vpc_id = aws_vpc.capstone_vpc.id
  
  ingress {
    description = "SSH from Application Server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.capstone-security-grp-rule.id]
  }

  ingress {
    description = "HTTPS from Application Server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.capstone-security-grp-rule.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_security_group.id]
    description = "Allow SSH access from the bastion host"
  }

  ingress {
    description = "HTTPS from Bastion Server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_security_group.id]
  }


  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.capstone-security-grp-rule.id]
    description = "Allow incoming MongoDB traffic from the frontend instance"
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
  name        = "monitoring-security-group"
  description = "Security group for monitoring server"
  vpc_id      = aws_vpc.capstone_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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

# Create key pair
resource "aws_key_pair" "Capstone_keypair" {
  key_name   = "Capstone_keypair"
  public_key = file("~/.ssh/id_rsa.pub")  
}

resource "aws_launch_configuration" "capstone-server" {
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.capstone-security-grp-rule.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.Capstone_keypair.key_name  # Use the created key pair

}

resource "aws_autoscaling_group" "capstone-server" {
  desired_capacity     = 2
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.capstone-public-subnet1.id, aws_subnet.capstone-public-subnet2.id]
  launch_configuration = aws_launch_configuration.capstone-server.name

  tag {
    key                 = "Name"
    value               = "capstone-server"
    propagate_at_launch = true
  }
}

# create bastion host

resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.Capstone_keypair.key_name 

  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  subnet_id              = aws_subnet.capstone-public-subnet1.id

  tags = {
    Name = "bastion-host"
  }
}

# create database instance

resource "aws_instance" "database_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.Capstone_keypair.key_name 

  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  subnet_id              = aws_subnet.capstone-private-subnet.id

  tags = {
    Name = "database-server"
  }
}

# create monitoring server

resource "aws_instance" "monitoring_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.Capstone_keypair.key_name

  vpc_security_group_ids = [aws_security_group.monitoring_security_group.id]
  subnet_id              = aws_subnet.capstone-public-subnet1.id

  tags = {
    Name = "monitoring-server"
  }
}





