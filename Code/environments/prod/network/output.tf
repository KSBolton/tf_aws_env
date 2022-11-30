# //////////////////////////////
# PROD NETWORK ROOT MODULE
# //////////////////////////////


output "pvt_subnets" {
  value     = module.network-prod.pvt_subnets
  sensitive = true
}

output "vpc_id" {
  value = module.network-prod.vpc_id
}

output "pvt_subnet_ids" {
  value = module.network-prod.pvt_subnet_ids
}

output "pub_subnet_ids" {
  value = module.network-prod.pub_subnet_ids
}