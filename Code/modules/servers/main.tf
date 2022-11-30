# //////////////////////////////
# SERVERS MODULE
# //////////////////////////////

#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use remote state to retrieve the data
data "terraform_remote_state" "net_infra" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "${var.env}-acs730-assign1" // Bucket where to SAVE Terraform State
    key    = "network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                 // Region where bucket is created
  }
}

# A list of EC2 instance objects defined by admin via tfvars.
locals {
  instance_config = [
    for instance in var.config_input : [
      for i in range(1, instance.counter + 1) : {
        instance_type = instance.type
        instance_name = "${instance.name}-${i}"
        az_name       = instance.az_name
      }
    ]
  ]
}

# Converts the list of objects to a simple list of EC2 configs.
locals {
  instance_configs = flatten(local.instance_config)
}

# Creates mapping private subnet AZs to subnet ID for use in EC2 creation.
locals {
  sub_map = { for sub in data.terraform_remote_state.net_infra.outputs.pvt_subnets : sub.availability_zone => sub.id }
}

locals {
  convention   = "${var.prefix}-${var.env}"
  default_tags = var.default_tags
  # Mapping used to ensure EC2 instances get appropriate user_data value
  user_data_map = {
    "nonprod"         = templatefile("${path.module}/install_httpd.sh.tpl", { env = upper(var.env) })
    "prod_us-east-1c" = file("${path.module}/start_fake_mysql.sh")
  }
}

resource "aws_instance" "pvt_svrs" {
  for_each                    = { for vm in local.instance_configs : vm.instance_name => vm }
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = each.value.instance_type
  key_name                    = var.env == "nonprod" ? aws_key_pair.nonprod_key[0].key_name : aws_key_pair.prod_key[0].key_name
  subnet_id                   = lookup(local.sub_map, each.value.az_name)
  vpc_security_group_ids      = var.env == "nonprod" ? [aws_security_group.vm_ssh_http[0].id] : each.value.az_name == "us-east-1b" ? [aws_security_group.vm_ssh[0].id] : [aws_security_group.vm_ssh_sql[0].id]
  associate_public_ip_address = false
  user_data                   = var.env == "nonprod" ? lookup(local.user_data_map, var.env) : var.env == "prod" && each.value.az_name == "us-east-1c" ? lookup(local.user_data_map, "${var.env}_${each.value.az_name}") : ""

  root_block_device {
    encrypted = false
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}-${each.value.instance_name}"
    }
  )
}
