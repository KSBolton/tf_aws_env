#!/bin/bash

# Installs MySQL client on Bastion as seen in instructions. Not used.
sudo echo nameserver 8.8.8.8 > /etc/resolv.conf
sudo yum -y update
sudo yum install mysql -y