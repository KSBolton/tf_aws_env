provider "aws" {
  region = module.globalvars.region
}

terraform {
  backend "s3" {
    bucket = "nonprod-acs730-assign1"
    key    = "server/terraform.tfstate"
    region = "us-east-1"
  }
}