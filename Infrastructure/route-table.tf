

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