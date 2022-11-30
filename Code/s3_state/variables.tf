# //////////////////////////////
# S3 BUCKET
# //////////////////////////////

variable "bucket_name" {
  type    = list(string)
  default = ["prod-acs730-assign1", "nonprod-acs730-assign1", "vpc-peer-acs730-assign1", "routing-acs730-assign1"]
}

variable "region" {
  type    = string
  default = "us-east-1"
}