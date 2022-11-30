# //////////////////////////////
# SERVERS MODULE
# //////////////////////////////

# variable "instance_type" {
#   description = "Type of the instance"
#   type        = map(string)
# }

variable "default_tags" {
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

variable "prefix" {
  type        = string
  description = "Name prefix"
}

variable "env" {
  type        = string
  description = "Deployment Environment"
}

variable "config_input" {
  type = list(object({
    name    = string
    type    = string
    counter = number
    az_name = string
  }))

  description = "The EC2 configuration, List of Objects/Dictionary"
}

variable "bastion_type" {
  type        = string
  description = "Controls the EC2 instance type for Bastion."
}