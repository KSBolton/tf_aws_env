# //////////////////////////////
# VPC PEERING
# //////////////////////////////

provider "aws" {
  region = module.globalvars.region
}

terraform {
  backend "s3" {
    bucket = "vpc-peer-acs730-assign1"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}