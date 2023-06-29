# Output Load balancer DNS name
output "elb_load_balancer_dns_name" {
  value = aws_lb.capstone_load_balancer.dns_name
}

# Output NAT gateway elastic IP
output "nat_gateway_public_ip" {
  value = aws_eip.database_eip.public_ip
}