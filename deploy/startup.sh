#!/bin/bash
# GCP Startup Script for Synthetix Lab

# Update and install dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker.io docker-compose-v2 git

# Configure Docker to use Google DNS (Prevents "Temporary failure in name resolution" during build)
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

# Enable and start Docker
systemctl daemon-reload
systemctl enable docker
systemctl restart docker

# Disable any internal firewalls that might block traffic
ufw disable || true
iptables -F || true

# Create the Flag
echo "VulnOS{p01s0n3d_th3_w3ll_3scap3d_th3_c0nta1n3r}" > /root/flag.txt
chmod 400 /root/flag.txt

# Create the lab directory and make sure it's clean for cloning
mkdir -p /opt/synthetix
cd /opt/synthetix
rm -rf ./* ./.[!.]* ./..?* 2>/dev/null || true

# Clone the vulnerable-labs repository
# GIT_TERMINAL_PROMPT=0 prevents the script from hanging indefinitely if the repo goes private
export GIT_TERMINAL_PROMPT=0
if ! git clone https://github.com/vulnerable-labs/synthetix.git .; then
    echo "CRITICAL ERROR: Failed to clone the Synthetix repository. Halting startup script to allow debugging."
    exit 1
fi

# Start the lab
# Note: Using the modern Docker Compose V2 plugin
if ! docker compose up -d --build; then
    echo "CRITICAL ERROR: Failed to build and start the Docker containers. Halting startup script to allow debugging."
    exit 1
fi

echo "Startup script execution completed. The lab infrastructure is configured."

# ==========================================
# Phase 2 & 3: VM Configuration and Scrubbing
# ==========================================

echo "Beginning Forensic Scrub and VM Preparation..."

# Step 1: Nuke Phantom Setup User
REAL_USER=$(logname 2>/dev/null || echo $SUDO_USER)

if [ -n "$REAL_USER" ] && [ "$REAL_USER" != "root" ] && [ "$REAL_USER" != "ubuntu" ] && [ "$REAL_USER" != "alex" ]; then
    echo "[!] Cleaning up setup user: $REAL_USER"
    pkill -u "$REAL_USER" || true
    userdel -r "$REAL_USER" 2>/dev/null || true
    echo "[+] Cleanup complete."
else
    echo "[*] No setup user to delete."
fi

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

# 1. Vacuum journald logs while the daemon is still running
journalctl --vacuum-time=1s || true
rm -rf /var/log/journal/*

# 2. Stop logging daemons
# Ubuntu 24.04 defaults to systemd-journald (rsyslog is no longer default)
systemctl stop rsyslog || true
systemctl stop systemd-journald || true

# 3. Shred system and auth logs
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

# 5. Empty the history files for all users
for home_dir in /root /home/*; do
    if [ -d "$home_dir" ]; then
        > "$home_dir/.bash_history" 2>/dev/null || true
    fi
done

# 6. Clear active memory history
echo "Scrub complete. The VM is fully prepared."
echo "You may now connect to the VM via its external IP to test the lab."
echo "When you are completely finished testing, MANUALLY stop the VM and take your snapshot!"
history -c || true
