#!/bin/bash

{{!--VMs in nonprod environment should serve a web traffic --}}
{{!--with a custom message that prints out your name, --}}
{{!--the name of the environment and the private --}}
{{!--IP address of the EC2 instance.--}}

sudo echo nameserver 8.8.8.8 > /etc/resolv.conf
sudo yum -y update
sudo yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
cat <<EOF > /var/www/html/index.html
<html>
<title>Kbolton3 - 153040209</title>
<h1>Hi, my name is Kamaal Bolton and I love Terraform! </h1>
<h1>This server's private IP is $myip</h1>
<h1><font color="red"> The current environment is ${env}</font></h1>
<br>Built by Terraform!
</html>
EOF
sudo systemctl start httpd
sudo systemctl enable httpd

touch /home/ec2-user/user_data_was_here