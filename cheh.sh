#!/bin/bash

# Update and upgrade the system
apt update && apt upgrade -y && apt full-upgrade -y && apt install curl socat -y

# Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6=1" >> /etc/sysctl.conf
sysctl -p

# Run ssh-calls.sh script
bash <(curl -Ls https://raw.githubusercontent.com/KhosroNet/Ssh-User-management/main/ssh-calls.sh --ipv4)

# Run block-iran.sh script
bash <(curl -Ls https://raw.githubusercontent.com/KhosroNet/Ssh-User-management/main/block-iran.sh --ipv4) -y

# Change SSH port to 443
sed -i 's/Port 22/Port 443/' /etc/ssh/sshd_config

# Restart SSH services
sudo systemctl restart ssh && sudo systemctl restart sshd

# Deny incoming connections on port 22
ufw deny 22

# Configure DNS settings
echo "DNS=1.1.1.1 1.0.0.1" >> /etc/systemd/resolved.conf

# Restart systemd-resolved service
systemctl restart systemd-resolved

# Configure cache clearing cron job
echo "*/45 * * * * root sync; echo 1 > /proc/sys/vm/drop_caches; sync; echo 2 > /proc/sys/vm/drop_caches; sync; echo 3 > /proc/sys/vm/drop_caches" >> /etc/crontab

# Apply the cron configuration
crontab /etc/crontab
