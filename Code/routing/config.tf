# //////////////////////////////
# ROUTING
# //////////////////////////////

provider "aws" {
  region = module.globalvars.region
}

terraform {
  backend "s3" {
    bucket = "routing-acs730-assign1"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}