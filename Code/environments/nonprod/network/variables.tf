variable "pvt_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "pub_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}