# //////////////////////////////
# ROUTING
# //////////////////////////////

module "globalvars" {
  source = "../modules/globalvars"
}

module "nonprodvars" {
  source = "../modules/nonprodvars"
}

module "prodvars" {
  source = "../modules/prodvars"
}

data "terraform_remote_state" "nonprod_net_vpc" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "nonprod-acs730-assign1"    // Bucket where to SAVE Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = module.globalvars.region    // Region where bucket is created
  }
}

data "terraform_remote_state" "prod_net_vpc" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "prod-acs730-assign1"       // Bucket where to SAVE Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = module.globalvars.region    // Region where bucket is created
  }
}

data "terraform_remote_state" "vpc_peer_info" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "vpc-peer-acs730-assign1"   // Bucket where to SAVE Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = module.globalvars.region    // Region where bucket is created
  }
}

locals {
  # Define the gateways/next hops needed for routes
  nonprod_nat_gw  = data.terraform_remote_state.nonprod_net_vpc.outputs.nat_gw_id[0]
  nonprod_inet_gw = data.terraform_remote_state.nonprod_net_vpc.outputs.inet_gw_id[0]
  vpc_peer_cxn    = data.terraform_remote_state.vpc_peer_info.outputs.vpc_peer_id
  # VPC and environment information needed for route resources
  prod_vpc_id    = data.terraform_remote_state.prod_net_vpc.outputs.vpc_id
  nonprod_vpc_id = data.terraform_remote_state.nonprod_net_vpc.outputs.vpc_id
  nonprod_env    = module.nonprodvars.nonprod_env
  prod_env       = module.prodvars.prod_env
  # Lists of subnet IDs
  prod_pvt_subnets    = data.terraform_remote_state.prod_net_vpc.outputs.pvt_subnet_ids
  nonprod_pvt_subnets = data.terraform_remote_state.nonprod_net_vpc.outputs.pvt_subnet_ids
  nonprod_pub_subnets = data.terraform_remote_state.nonprod_net_vpc.outputs.pub_subnet_ids
}
##################################################################
resource "aws_route_table" "prod_pvt_rtb" {
  vpc_id = local.prod_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.vpc_peer_cxn
  }

  dynamic "route" {
    for_each = toset(["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"])

    content {
      cidr_block = route.value
      gateway_id = local.vpc_peer_cxn
    }
  }

  tags = merge(
    module.globalvars.default_tags, {
      Name = "${local.prod_env}_pvt_rtb"
    }
  )
}

resource "aws_route_table_association" "prod_pvt_rtb_assoc" {
  for_each       = toset(local.prod_pvt_subnets)
  subnet_id      = each.key
  route_table_id = aws_route_table.prod_pvt_rtb.id
}
##################################################################
resource "aws_route_table" "nonprod_pvt_rtb" {
  vpc_id = local.nonprod_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.nonprod_nat_gw
  }

  dynamic "route" {
    for_each = toset(["10.100.3.0/24", "10.100.4.0/24"])

    content {
      cidr_block = route.value
      gateway_id = local.vpc_peer_cxn
    }
  }

  tags = merge(
    module.globalvars.default_tags, {
      Name = "${local.nonprod_env}_pvt_rtb"
    }
  )
}

resource "aws_route_table_association" "nonprod_pvt_rtb_assoc" {
  for_each       = toset(local.nonprod_pvt_subnets)
  subnet_id      = each.key
  route_table_id = aws_route_table.nonprod_pvt_rtb.id
}
##################################################################
resource "aws_route_table" "nonprod_pub_rtb" {
  vpc_id = local.nonprod_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.nonprod_inet_gw
  }

  dynamic "route" {
    for_each = toset(["10.100.3.0/24", "10.100.4.0/24"])

    content {
      cidr_block = route.value
      gateway_id = local.vpc_peer_cxn
    }
  }

  tags = merge(
    module.globalvars.default_tags, {
      Name = "${local.nonprod_env}_pub_rtb"
    }
  )
}

resource "aws_route_table_association" "nonprod_pub_rtb_assoc" {
  for_each       = toset(local.nonprod_pub_subnets)
  subnet_id      = each.key
  route_table_id = aws_route_table.nonprod_pub_rtb.id
}