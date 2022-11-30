#!/bin/bash

# Fake MySQL since this EC2 instance can't reach out to the Internet via the nonprod VPC
# Reminder: VPC peering isn't transitive, traffic won't go through the nonprod VPC w/o additional configuration & complexity.
# Starts Python web server running on TCP/3306 i.e. MySQL's default port.
python3 -m http.server 3306