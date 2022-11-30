# //////////////////////////////
# NONPROD NETWORK ROOT MODULE
# //////////////////////////////

output "pvt_subnets" {
  value     = module.network-nonprod.pvt_subnets
  sensitive = true
}

output "vpc_id" {
  value = module.network-nonprod.vpc_id
}

output "pvt_subnet_ids" {
  value = module.network-nonprod.pvt_subnet_ids
}

output "pub_subnet_ids" {
  value = module.network-nonprod.pub_subnet_ids
}

output "nat_gw_id" {
  value = module.network-nonprod.nat_gw_id
}

output "inet_gw_id" {
  value = module.network-nonprod.inet_gw_id
}