/*Edit the name, type or counter values below to make changes to the envvironment.
The az_name value must remain unchanged but that functionality is in the pipeline. */

config_input = [
  {
    "name" : "VM1_ssh_web",
    "type" : "t2.micro",
    "counter" : 1,
    "az_name" : "us-east-1b"
  },
  {
    "name" : "VM2_ssh_web",
    "type" : "t2.micro",
    "counter" : 1,
    "az_name" : "us-east-1c"
  }
]