module "globalvars" {
  source = "../../../modules/globalvars"
}

module "prodvars" {
  source = "../../../modules/prodvars"
}

module "network-prod" {
  source           = "../../../modules/network"
  env              = module.prodvars.prod_env
  vpc_cidr         = module.prodvars.vpc_cidr
  pvt_subnet_cidrs = var.pvt_subnet_cidrs
  pub_subnet_cidrs = var.pub_subnet_cidrs
  prefix           = module.globalvars.prefix
  default_tags     = module.globalvars.default_tags
  azs              = data.aws_availability_zones.azs
}

data "aws_availability_zones" "azs" {
  state = "available"

  filter {
    name   = "region-name"
    values = ["${module.globalvars.region}"]
  }
}