#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- Starting Conduit Node Installation (Official CLI Method) ---${NC}"

# 1. Update and install basic requirements
echo -e "${GREEN}[1/5] Installing dependencies (wget, tar)...${NC}"
sudo apt update && sudo apt install -y wget tar

# 2. Create the project and data directory
# The data directory is crucial for preserving the node identity key
echo -e "${GREEN}[2/5] Setting up directory at ~/conduit-node...${NC}"
mkdir -p ~/conduit-node/data
cd ~/conduit-node

# 3. Download the latest official release (v1.0.5)
# Official releases include an embedded psiphon config
echo -e "${GREEN}[3/5] Downloading official Conduit binary...${NC}"
wget https://github.com/Psiphon-Inc/conduit/releases/download/v1.0.5/conduit-linux-amd64.tar.gz
tar -xvf conduit-linux-amd64.tar.gz
chmod +x conduit

# 4. Create a Systemd service to run in background
echo -e "${GREEN}[4/5] Creating background service...${NC}"
sudo cat <<EOF > /etc/systemd/system/conduit.service
[Unit]
Description=Psiphon Conduit Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$(pwd)
# Parameters based on official recommendations
ExecStart=$(pwd)/conduit start --data-dir $(pwd)/data --bandwidth 40 --max-clients 50
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 5. Launch the service
echo -e "${GREEN}[5/5] Enabling and starting Conduit node...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable conduit
sudo systemctl start conduit

echo -e "${BLUE}----------------------------------------${NC}"
echo -e "${GREEN}Installation Success! 🚀${NC}"
echo -e "Node key saved in: ${BLUE}$(pwd)/data/conduit_key.json${NC}"
echo -e "To see live logs, run: ${BLUE}journalctl -u conduit -f${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
