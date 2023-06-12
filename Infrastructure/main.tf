provider "aws" {
  region = vars.region
}

# Save state-file in an S3 bucket
terraform {
  backend "s3" {
    bucket         = "capstone-state-bucket"
    key            = "terraform.tfstate"
    region         = vars.region
  }
}

# Create a VPC
resource "aws_vpc" "capstone_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "capstoneVPC"
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

# Create Public Subnet-1
resource "aws_subnet" "capstone-public-subnet1" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = vars.av-zone1
  tags = {
    Name = "capstone-public-subnet1"
  }
}

# Create Public Subnet-2
resource "aws_subnet" "capstone-public-subnet2" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = vars.av-zone2
  tags = {
    Name = "capstone-public-subnet2"
  }
}

# Create a private subnet
resource "aws_subnet" "capstone-private-subnet" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = vars.av-zone1

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
    from_port   = 2200
    to_port     = 2200
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_security_group.id]
    description = "Allow SSH access from the bastion host"
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