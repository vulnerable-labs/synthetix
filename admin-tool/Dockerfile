FROM ubuntu:24.04

# Install python, docker cli
RUN apt-get update && apt-get install -y \
    python3 python3-pip docker.io sudo curl \
    && rm -rf /var/lib/apt/lists/*

# Create www-data user if not exists (ubuntu base usually has it, but let's ensure)
RUN id -u www-data &>/dev/null || useradd -r -s /bin/false www-data

WORKDIR /app
COPY requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

COPY admin_bot.py run.sh ./
RUN chmod +x run.sh

# We run as root initially to set permissions on the mounted docker socket
# and then drop privileges to www-data using the run.sh script.
CMD ["./run.sh"]
