# //////////////////////////////
# VPC PEERING
# //////////////////////////////

# Used in routing module to specify next-hop for routes
output "vpc_peer_id" {
  value = aws_vpc_peering_connection.vpc_peer_cxn.id
}