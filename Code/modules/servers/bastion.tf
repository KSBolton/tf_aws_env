# //////////////////////////////
# SERVERS MODULE
# //////////////////////////////

resource "aws_instance" "nonprod_bastion" {
  count                       = var.env == "nonprod" ? 1 : 0
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.bastion_type
  key_name                    = aws_key_pair.nonprod_key[0].key_name
  subnet_id                   = data.terraform_remote_state.net_infra.outputs.pub_subnet_ids[1]
  vpc_security_group_ids      = [aws_security_group.bastion_ssh[0].id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/install_mysql.sh")

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.convention}-bastion-${count.index}"
    }
  )
}