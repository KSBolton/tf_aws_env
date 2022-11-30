# //////////////////////////////
# NETWORK MODULE
# //////////////////////////////

locals {
  convention = "${var.prefix}-${var.env}"
  default_tags = var.default_tags
}

resource "aws_vpc" "net_space" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${local.convention}-vpc"
    }
  )  
}

resource "aws_subnet" "pvt_subnet" {
  count             = length(var.pvt_subnet_cidrs)
  vpc_id            = aws_vpc.net_space.id
  cidr_block        = var.pvt_subnet_cidrs[count.index]
  availability_zone = var.azs.names[count.index + 1]
  tags = merge(
    local.default_tags, {
      Name = "${local.convention}-pvt-subnet-${count.index + 1}"
      Environment = var.env
    }
  )
}

resource "aws_subnet" "pub_subnet" {
  count  = var.env == "nonprod" ? length(var.pub_subnet_cidrs) : 0
  vpc_id            = aws_vpc.net_space.id
  cidr_block        = var.pub_subnet_cidrs[count.index]
  availability_zone = var.azs.names[count.index + 1]
  tags = merge(
    local.default_tags, {
      Name = "${local.convention}-pub-subnet-${count.index + 1}"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  count  = var.env == "nonprod" ? 1 : 0
  vpc_id = aws_vpc.net_space.id

  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}-igw"
    }
  )
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat_gw_eip" {
  count  = var.env == "nonprod" ? 1 : 0
  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}-eip"
    }
  )
}


resource "aws_nat_gateway" "nat_gw" {
  count  = var.env == "nonprod" ? 1 : 0
  allocation_id = aws_eip.nat_gw_eip[count.index].id
  subnet_id     = aws_subnet.pub_subnet[0].id

  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}-natgw"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC. Following Hashicorp suggestion here.
  depends_on = [aws_internet_gateway.igw]
}