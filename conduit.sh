#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- Starting Conduit Node Installation ---${NC}"

# 1. Update system packages
echo -e "${GREEN}[1/5] Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# 2. Install Docker & Docker Compose if not present
if ! command -v docker &> /dev/null; then
    echo -e "${GREEN}[2/5] Installing Docker and Docker Compose...${NC}"
    sudo apt install -y docker.io docker-compose
    sudo systemctl enable --now docker
else
    echo -e "${BLUE}[2/5] Docker is already installed.${NC}"
fi

# 3. Create project directory
echo -e "${GREEN}[3/5] Setting up project directory at ~/conduit-node...${NC}"
mkdir -p ~/conduit-node/data
cd ~/conduit-node

# 4. Create docker-compose.yml
echo -e "${GREEN}[4/5] Creating configuration file...${NC}"
cat <<EOT > docker-compose.yml
version: '3'
services:
  conduit:
    image: ghcr.io/psiphon-inc/conduit:latest
    container_name: conduit
    restart: always
    volumes:
      - ./data:/data
    # Parameters: 40Mbps limit, 50 max concurrent clients
    command: start --data-dir /data --bandwidth 40 --max-clients 50
EOT

# 5. Launch the container
echo -e "${GREEN}[5/5] Launching Conduit node...${NC}"
sudo docker-compose up -d

echo -e "${BLUE}----------------------------------------${NC}"
echo -e "${GREEN}Installation Complete! 🚀${NC}"
echo -e "To check your node status, run:"
echo -e "${BLUE}cd ~/conduit-node && sudo docker-compose logs -f${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
