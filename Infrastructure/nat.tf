
# Create a NAT gateway
resource "aws_nat_gateway" "database_nat_gateway" {
  allocation_id = aws_eip.database_eip.id
  subnet_id     = aws_subnet.capstone_public_subnet1.id
}

# Create Elastic IP
resource "aws_eip" "database_eip" {
  domain = "vpc"
}
