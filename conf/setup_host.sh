#!/bin/bash

# Extract and store the IP address from the output of ifconfig in a variable
ip_address=$(ifconfig | grep 'inet ' | awk '{print $2}' | cut -d':' -f2)

# Add 4 spaces and 'restaurant' after the IP address, then echo that to /etc/hosts
echo "$ip_address    restaurant" >> /etc/hosts
