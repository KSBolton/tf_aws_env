# Introduction

These HCL modules work together to create a customizable and secure network infrastructure consisting of two VPCs linked via a VPC peering connection, a NAT gateway, Internet gateway, EC2 instances, and a Bastion host allowing connectivity from external administrators.

They have been specifically designed to be applied within a specific order.

## How to use

The folder structure is as seen below:

```
├── environments
│   ├── nonprod
│   │   ├── network
│   │   │   └── plans
│   │   └── servers
│   │       ├── keys
│   │       └── plans
│   └── prod
│       ├── network
│       │   └── plans
│       └── servers
│           ├── keys
│           └── plans
├── modules
│   ├── globalvars
│   ├── network
│   ├── nonprodvars
│   ├── prodvars
│   └── servers
├── routing
│   └── plans
├── s3_state
│   └── plans
└── vpc_peering
    └── plans
 ```

The modules should be run in the following order. Deviations from this order might cause unexpected results.

1. s3_state (*Creates all the buckets to be used*)
1. nonprod/network (*Creates VPC, subnets, Internet and NAT gateways*) 
1. nonprod/servers (*Creates the EC2 instances, security groups, etc.*) 
1. prod/network (*Creates VPC and subnets*) 
1. prod/servers (*Creates the EC2 instances, security groups, etc.*) 
1. vpc-peering (*Takes VPC information from each environment to configure peer link*)
1. routing (*Creates routing tables and routes, then assigns them to subnets*)

# Steps to Deploy:

1. Browse to **s3_state** directory.
1. Run the `terraform init`, `terraform plan` and `terraform apply` commands to create 4 buckets: production, nonproduction, vpc peering, and routing.
1. Browse to **environments/nonprod/network** directory.
1. Run the `terraform init`, `terraform plan` and `terraform apply` commands to create nonproduction network infrastructure.
1. Browse to **environments/nonprod/servers** directory.
1. Create a **keys** directory via `mkdir keys` command.
1. Run `ssh-keygen -t rsa -f keys/nonprod-key` to create a key pair for EC2 creation. Optionally, you may provide a passphrase for the private key.
1. Run the `terraform init`, `terraform plan` and `terraform apply -var-file=default.tfvars` commands to create nonproduction EC2 instances.
	1. Note the *-var-file=default.tfvars* argument which contains some of the configuration for EC2 instances.
1. Save the Bastion public IP address that shows at the end of the apply operation. It will be used later.
1. Browse to **environments/prod/network** directory.
1. Run the `terraform init`, `terraform plan` and `terraform apply` commands to create production network infrastructure.
1. Browse to **environments/prod/servers** directory.
1. Create a **keys** directory via `mkdir keys` command.
1. Run `ssh-keygen -t rsa -f keys/prod-key` to create a key pair for EC2 creation. Optionally, you may provide a passphrase for the private key.
1. Run the `terraform init`, `terraform plan` and `terraform apply -var-file=default.tfvars` commands to create production EC2 instances.
	1. Note the *-var-file=default.tfvars* argument which contains some of the configuration for EC2 instances.
1. Browse to **vpc_peering** directory.
1. Run the `terraform init`, `terraform plan` and `terraform apply` commands to create the VPC peering connection.
1. Browse to **routing** directory.
1. Run the `terraform init`, `terraform plan` and `terraform apply` commands to create the route tables and routes across both VPCs.


> Note: Alternatively, custom *.tfvars* files can be used as long as they adhere to the schema seen in default.tfvars.

Schema:

```sh
config_input = [
  {
  	# EC2 Instance Object 1
    "name" : <EC2 instance name, string value>,
    "type" : <EC2 instance type, string value>,
    "counter" : <Number of EC2 instances, integer value>,
    "az_name" : <Availability Zone name, string value>
  },
  {
  	# EC2 Instance Object 2
    "name" : <EC2 instance name, string value>,
    "type" : <EC2 instance type, string value>,
    "counter" : <Number of EC2 instances, integer value>,
    "az_name" : <Availability Zone name, string value>
  }
]
```

> Note: Please note, you may add more Instance Objects as needed but if you want to have multiple copies of the same resource, please increment the counter attribute.

# Steps to access private resources via Bastion public IP:

1. On an admin machine running OpenSSH, open a terminal window.
1. Collect the Bastion public IP (bastion_pub_ip) address output after deploying the **environments/nonprod/servers** module.
1. Collect the prod and nonprod private keys you've generated and place them in reachable locations.
1. At the command prompt, run ssh -i <path-to-nonprod-private-key> ec2-user@<Bastion-public-ip> -L <local-port>:<private-ip-of-private-ec2>:<destination-port-on-private-ec2>
1. Now an SSH tunnel has been established with the Bastion EC2 instance, via which traffic to private EC2 instances will traverse (see SSH Tunneling)
1. To access websites in nonprod private EC2 instances, set the -L values to <local-port>:<private-ip-of-private-ec2>:80 and browse to http://localhost:<local-port> via a  web browser.
1. To access SSH servers in any of the private EC2 instances, set the -L values to <local-port>:<private-ip-of-private-ec2>:22 and use a separate CLI terminal window to run this command: ssh -i <path-to-appropriate-private-key> ec2-user@localhost -p <local-port>
1. To access the "MySQL server" bonus, set the -L values to <local-port>:<private-ip-of-private-ec2>:3306 and browse to http://localhost:<local-port> via a  web browser.
  1. Note, this is a simulation where the TCP port for MySQL has been configured as the listening port for a Python HTTP web server module and so browsing to the localhost address mentioned here will show a basic webpage listing a directory's contents.

# Steps to Clean Up:

Destroying the deployed resources requires that the modules are accessed in the reverse order.


1. Browse to **routing** directory.
1. Run the `terraform destroy` command to remove the route tables and routes across both VPCs.
1. Browse to **vpc_peering** directory.
1. Run the `terraform destroy` command to remove the VPC peering connection.
1. Browse to **environments/nonprod/servers** directory.
1. Run the `terraform destroy -var-file=default.tfvars` command to remove nonproduction EC2 instances.
	1. Note the *-var-file=default.tfvars* argument which contains some of the configuration for EC2 instances.
1. Browse to **environments/nonprod/network** directory.
1. Run the `terraform destroy` command to remove nonproduction network infrastructure.
1. Browse to **environments/prod/servers** directory.
1. Run the `terraform destroy -var-file=default.tfvars` command to remove production EC2 instances.
	1. Note the *-var-file=default.tfvars* argument which contains some of the configuration for EC2 instances.	
1. Browse to **environments/prod/network** directory.
1. Run the `terraform destroy` command to remove production network infrastructure.
1. Browse to **s3_state directory**.
1. Run the `terraform destroy` command to remove 4 buckets: production, nonproduction, vpc peering, and routing.
