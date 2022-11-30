variable "config_input" {
  description = "The total configuration, List of Objects/Dictionary"
  default     = [{}]
}

variable "bastion_type" {
  type = string
  # Empty since prod has no bastion but is available in case of growth.
  default     = ""
  description = "Controls the EC2 instance type for Bastion."
}