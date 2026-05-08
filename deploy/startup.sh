#!/bin/bash
# GCP Startup Script for Synthetix Lab

# Update and install dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker.io docker-compose git

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Create the Flag
echo "VulnOS{p01s0n3d_th3_w3ll_3scap3d_th3_c0nta1n3r}" > /root/flag.txt
chmod 400 /root/flag.txt

# Create the lab directory
mkdir -p /opt/synthetix
cd /opt/synthetix

# Note: In a real GCP deployment, you would git clone your repository here:
# git clone https://github.com/yourusername/synthetix.git .
# Since this is a template, we assume the user will configure the repo URL.

# Start the lab
# docker-compose up -d --build

echo "Startup script execution completed. If the repository was cloned, the lab should be starting."
