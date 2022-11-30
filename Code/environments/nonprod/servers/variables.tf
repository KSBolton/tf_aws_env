variable "config_input" {
  description = "The total configuration, List of Objects/Dictionary"
  default     = [{}]
}

variable "bastion_type" {
  type        = string
  default     = "t2.micro"
  description = "Controls the EC2 instance type for Bastion."
}