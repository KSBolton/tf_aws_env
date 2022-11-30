# //////////////////////////////
# SERVERS MODULE
# //////////////////////////////

# Making two separate key pair resources to make it easier for managing them 
# individually e.g. updating one wouldnot affect the other.
resource "aws_key_pair" "nonprod_key" {
  count      = var.env == "nonprod" ? 1 : 0
  key_name   = "${local.convention}-key"
  public_key = file("./keys/${var.env}-key.pub")
}

resource "aws_key_pair" "prod_key" {
  count      = var.env == "prod" ? 1 : 0
  key_name   = "${local.convention}-key"
  public_key = file("./keys/${var.env}-key.pub")
}