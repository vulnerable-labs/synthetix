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

# Clone the vulnerable-labs repository
git clone https://github.com/vulnerable-labs/synthetix.git .

# Start the lab
# Note: Ubuntu 24.04 utilizes docker-compose-v2, so the command is 'docker compose'
docker compose up -d --build

echo "Startup script execution completed. The lab infrastructure is configured."

# ==========================================
# Phase 2 & 3: VM Configuration and Scrubbing
# ==========================================

echo "Beginning Forensic Scrub and VM Preparation..."

# Step 1: Nuke Phantom Users 
# Automatically detects and deletes any users injected by GCP (e.g., 'gaurav') while preserving 'ubuntu'
for phantom_user in $(awk -F: '$3 >= 1000 && $1 != "ubuntu" && $1 != "nobody" {print $1}' /etc/passwd); do
    echo "Nuking phantom user: $phantom_user"
    pkill -u "$phantom_user" || true
    userdel -r "$phantom_user" || true
done

# Step 2: Gag the Google Guest Agent
# Prevents GCP from overwriting the OS hostname on boot
cat <<EOF > /etc/default/instance_configs.cfg
[InstanceSetup]
set_hostname = false
EOF

# Step 3: Lock Cloud-Init
# Ensure generic Linux startup scripts don't reset the network name
if ! grep -q "preserve_hostname: true" /etc/cloud/cloud.cfg; then
    echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
fi

# Step 4: Set the Target Hostname
hostnamectl set-hostname synthetix
sed -i 's/127.0.1.1.*/127.0.1.1 synthetix/' /etc/hosts

# Phase 3: The Ultimate Forensic Scrub
# 1. Stop logging daemons
# Ubuntu 24.04 defaults to systemd-journald (rsyslog is no longer default)
systemctl stop rsyslog || true
systemctl stop systemd-journald || true

# 2. Shred system and auth logs (including journald logs)
journalctl --vacuum-time=1s || true
rm -rf /var/log/journal/*
truncate -s 0 /var/log/auth.log 2>/dev/null || true
truncate -s 0 /var/log/syslog 2>/dev/null || true
truncate -s 0 /var/log/kern.log 2>/dev/null || true
truncate -s 0 /var/log/wtmp 2>/dev/null || true
truncate -s 0 /var/log/btmp 2>/dev/null || true
truncate -s 0 /var/log/lastlog 2>/dev/null || true

# 3. Wipe Cloud-Init and Temp build files
rm -rf /var/log/cloud-init*.log
rm -rf /tmp/*
rm -rf /var/tmp/*

# 4. Stop the current bash shell from recording history on exit
unset HISTFILE

# 5. Empty the history files
> /root/.bash_history

# 6. Clear active memory history and force immediate shutdown
# The VM will shut down, making it perfectly pristine for a GCP Image Snapshot
echo "Scrub complete. Shutting down the machine for image creation."
history -c && shutdown -h now
