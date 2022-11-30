variable "pvt_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
  default     = ["10.100.3.0/24", "10.100.4.0/24"]
}

variable "pub_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
  default     = [""]
}