#!/bin/bash

# Define variables
WORKDIR="$HOME/conduit"
SERVICE_NAME="conduit"
DOWNLOAD_URL="https://github.com/Psiphon-Inc/conduit/releases/download/v1.0.1/conduit-1.0.1-linux-amd64.tar.gz"

echo "1. Creating directory: $WORKDIR"
mkdir -p $WORKDIR
cd $WORKDIR

echo "2. Downloading Conduit v1.0.1..."
wget -O conduit.tar.gz "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    echo "Error: Download failed. Check your internet connection."
    exit 1
fi

echo "3. Extracting files..."
tar -xvf conduit.tar.gz
chmod +x conduit

echo "4. Creating Systemd Service..."
sudo bash -c "cat <<EOT > /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=Psiphon Conduit Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$WORKDIR
ExecStart=$WORKDIR/conduit start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOT"

echo "5. Reloading systemd and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "------------------------------------------------"
echo "DONE! Conduit is now running in the background."
echo "Check status with: sudo systemctl status $SERVICE_NAME"
echo "View logs with: sudo journalctl -u $SERVICE_NAME -f"
echo "------------------------------------------------"
