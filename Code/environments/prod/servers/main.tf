module "globalvars" {
  source = "../../../modules/globalvars"
}

module "prodvars" {
  source = "../../../modules/prodvars"
}

module "svr-prod" {
  source = "../../../modules/servers"
  env    = module.prodvars.prod_env
  prefix       = module.globalvars.prefix
  default_tags = module.globalvars.default_tags
  config_input = var.config_input
  bastion_type = var.bastion_type
}