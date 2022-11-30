# //////////////////////////////
# SERVERS MODULE
# //////////////////////////////

output "bastion_pvt_ip" {
  value = var.env == "nonprod" ? aws_instance.nonprod_bastion[0].private_ip : ""
}

output "bastion_pub_ip" {
  value = var.env == "nonprod" ? aws_instance.nonprod_bastion[0].public_ip : ""
}