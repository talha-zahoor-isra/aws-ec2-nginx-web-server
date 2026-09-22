#!/bin/bash

# Update Ubuntu packages
sudo apt update

# Install Nginx
sudo apt install nginx -y

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Test Nginx configuration
sudo nginx -t

# Check Nginx status
sudo systemctl status nginx --no-pager