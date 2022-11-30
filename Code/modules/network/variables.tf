variable "default_tags" {
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

variable "prefix" {
  type        = string
  description = "Name prefix"
}

variable "pvt_subnet_cidrs" {
  type        = list(string)
  description = "Provision public subnet CIDRs in custom VPC"
}

variable "pub_subnet_cidrs" {
  type        = list(string)
  description = "Provision private subnet CIDRs in custom VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "/16 IP address space for VPC"
}

variable "env" {
  type        = string
  description = "Deployment Environment"
}

variable "azs" {
  description = "Results from AZ data block"
}