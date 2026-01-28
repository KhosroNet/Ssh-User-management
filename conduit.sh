#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- Starting Conduit Node Installation (Binary Method) ---${NC}"

# 1. Install basic requirements
echo -e "${GREEN}[1/5] Installing wget and tar...${NC}"
sudo apt update && sudo apt install -y wget tar

# 2. Setup project directory
# We use a persistent directory to preserve the identity key
echo -e "${GREEN}[2/5] Setting up directory at ~/conduit-node...${NC}"
mkdir -p ~/conduit-node/data
cd ~/conduit-node

# 3. Download the official release
# This includes the embedded config mentioned in the docs
echo -e "${GREEN}[3/5] Downloading latest Conduit release...${NC}"
wget https://github.com/Psiphon-Inc/conduit/releases/download/v1.0.5/conduit-linux-amd64.tar.gz
tar -xvf conduit-linux-amd64.tar.gz
chmod +x conduit

# 4. Create a Systemd Service for background execution
echo -e "${GREEN}[4/5] Creating system service...${NC}"
sudo cat <<EOF > /etc/systemd/system/conduit.service
[Unit]
Description=Psiphon Conduit Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$(pwd)
# Using standard flags: 40Mbps bandwidth and 50 max clients
ExecStart=$(pwd)/conduit start --data-dir $(pwd)/data --bandwidth 40 --max-clients 50
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 5. Launch the service
echo -e "${GREEN}[5/5] Starting Conduit service...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable conduit
sudo systemctl start conduit

echo -e "${BLUE}----------------------------------------${NC}"
echo -e "${GREEN}Installation Successful! 🚀${NC}"
echo -e "Your Node Key is safe in: ${BLUE}$(pwd)/data/conduit_key.json${NC}"
echo -e "To view live logs, run: ${BLUE}journalctl -u conduit -f${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
