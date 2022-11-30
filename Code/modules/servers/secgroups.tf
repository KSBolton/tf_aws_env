# //////////////////////////////
# SERVERS MODULE
# //////////////////////////////

data "http" "admin_public_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "terraform_remote_state" "nonprod_server_info" {
  count  = var.env == "prod" ? 1 : 0
  backend = "s3"
  config = {
    bucket = "nonprod-acs730-assign1" // Bucket where to SAVE Terraform State
    key    = "server/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                 // Region where bucket is created
  }  
}

resource "aws_security_group" "bastion_ssh" {
  count       = var.env == "nonprod" ? 1 : 0
  name        = "${local.convention}_bastion_ssh"
  vpc_id      = data.terraform_remote_state.net_infra.outputs.vpc_id
  description = "Management admin access."

  ingress {
    description = "SSH from admin and PC Rogers ASN IP range."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.admin_public_ip.response_body)}/32", "99.224.0.0/11"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}_bastion_ssh"
    }
  )
}

resource "aws_security_group" "vm_ssh" {
  count  = var.env == "prod" ? 1 : 0
  name   = "${local.convention}_ssh"
  vpc_id = data.terraform_remote_state.net_infra.outputs.vpc_id

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.nonprod_server_info[0].outputs.bastion_pvt_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}_vm_ssh"
    }
  )
}

resource "aws_security_group" "vm_ssh_http" {
  count  = var.env == "nonprod" ? 1 : 0
  name   = "${local.convention}_ssh_http"
  vpc_id = data.terraform_remote_state.net_infra.outputs.vpc_id

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["${aws_instance.nonprod_bastion[0].private_ip}/32"]
  }

  ingress {
    description     = "HTTP from Bastion"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["${aws_instance.nonprod_bastion[0].private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}_vm_ssh_http"
    }
  )
}

resource "aws_security_group" "vm_ssh_sql" {
  count  = var.env == "prod" ? 1 : 0
  name   = "${local.convention}_ssh_sql"
  vpc_id = data.terraform_remote_state.net_infra.outputs.vpc_id

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.nonprod_server_info[0].outputs.bastion_pvt_ip}/32"]
  }

  # BONUS! SQL rule allows MySQL default port, TCP/3306.
  ingress {
    description = "SQL from Bastion"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.nonprod_server_info[0].outputs.bastion_pvt_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}_vm_ssh_sql"
    }
  )
}