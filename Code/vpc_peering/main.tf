# //////////////////////////////
# VPC PEERING
# //////////////////////////////

module "globalvars" {
  source = "../modules/globalvars"
}

data "terraform_remote_state" "prod_net_vpc" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "prod-acs730-assign1"       // Bucket where to SAVE Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                 // Region where bucket is created
  }
}

data "terraform_remote_state" "nonprod_net_vpc" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "nonprod-acs730-assign1"    // Bucket where to SAVE Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                 // Region where bucket is created
  }
}

# A VPC peering connection is a networking connection between two VPCs that enables you to route traffic between them using private IPv4 addresses or IPv6 addresses.
resource "aws_vpc_peering_connection" "vpc_peer_cxn" {
  peer_vpc_id = data.terraform_remote_state.prod_net_vpc.outputs.vpc_id
  vpc_id      = data.terraform_remote_state.nonprod_net_vpc.outputs.vpc_id
  auto_accept = "true"

  tags = merge(
    module.globalvars.default_tags, {
      Name = "${module.globalvars.prefix}-vpc-peer"
    }
  )
}