#!/bin/bash

# Ensure the docker socket is writable by anyone in the container
# This simulates a highly privileged misconfiguration.
if [ -S /var/run/docker.sock ]; then
    chmod 666 /var/run/docker.sock
fi

# Drop privileges to www-data and run the python bot
sudo -u www-data python3 /app/admin_bot.py
