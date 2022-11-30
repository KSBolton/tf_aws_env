# //////////////////////////////
# NETWORK MODULE
# //////////////////////////////

# Add output variables
output "pvt_subnet_ids" {
  value = aws_subnet.pvt_subnet[*].id
}

output "pub_subnet_ids" {
  value = aws_subnet.pub_subnet[*].id
}

output "pvt_subnets" {
  value = aws_subnet.pvt_subnet
}

output "vpc_id" {
  value = aws_vpc.net_space.id
}

output "nat_gw_id" {
  value = aws_nat_gateway.nat_gw[*].id
}

output "inet_gw_id" {
  value = aws_internet_gateway.igw[*].id
}