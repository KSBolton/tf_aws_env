module "globalvars" {
  source = "../../../modules/globalvars"
}

module "nonprodvars" {
  source = "../../../modules/nonprodvars"
}

module "svr-nonprod" {
  source = "../../../modules/servers"
  env    = module.nonprodvars.nonprod_env
  prefix       = module.globalvars.prefix
  default_tags = module.globalvars.default_tags
  config_input = var.config_input
  bastion_type = var.bastion_type
}