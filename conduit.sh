#!/bin/bash

# Conduit Docker Installation Script
# This script sets up a Conduit node using Docker on Linux

set -e

echo "====================================="
echo "Conduit Docker Installation Script"
echo "====================================="
echo ""

# Check if old installation exists
PROJECT_DIR="/root/conduit"
if [ -d "$PROJECT_DIR" ]; then
    echo "Found existing Conduit installation at $PROJECT_DIR"
    echo "Stopping and removing old installation..."
    
    cd "$PROJECT_DIR"
    
    # Stop and remove old containers
    if [ -f "docker-compose.yml" ]; then
        docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true
    fi
    
    # Backup data directory if exists
    if [ -d "data" ]; then
        echo "Backing up existing data directory..."
        BACKUP_DIR="/root/conduit_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp -r data "$BACKUP_DIR/"
        echo "Data backed up to: $BACKUP_DIR"
    fi
    
    # Remove old installation
    cd /root
    rm -rf "$PROJECT_DIR"
    echo "Old installation removed."
    echo ""
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    
    # Install docker-compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# Create project directory
echo ""
echo "Creating project directory at $PROJECT_DIR..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create data directory for persistent storage
echo "Creating data directory..."
mkdir -p data

# Restore backed up data if exists
LATEST_BACKUP=$(ls -td /root/conduit_backup_* 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ] && [ -d "$LATEST_BACKUP/data" ]; then
    echo "Restoring data from backup..."
    cp -r "$LATEST_BACKUP/data/"* data/ 2>/dev/null || true
    echo "Data restored from backup."
fi

# Create docker-compose.yml
echo "Creating docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  conduit:
    image: psiphoninc/conduit:latest
    container_name: conduit
    restart: unless-stopped
    volumes:
      - ./data:/data
    ports:
      - "8080:8080"
    environment:
      - MAX_CLIENTS=50
      - BANDWIDTH=40
    command: start --data-dir /data -v
EOF

echo "docker-compose.yml created successfully."
echo ""

# Create a simple management script
echo "Creating management script..."
cat > manage.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "Starting Conduit..."
        docker-compose up -d
        echo "Conduit started. Use './manage.sh logs' to view logs."
        ;;
    stop)
        echo "Stopping Conduit..."
        docker-compose down
        echo "Conduit stopped."
        ;;
    restart)
        echo "Restarting Conduit..."
        docker-compose restart
        echo "Conduit restarted."
        ;;
    logs)
        docker-compose logs -f
        ;;
    status)
        docker-compose ps
        ;;
    update)
        echo "Updating Conduit..."
        docker-compose pull
        docker-compose up -d
        echo "Conduit updated."
        ;;
    uninstall)
        echo "Uninstalling Conduit..."
        read -p "Are you sure? This will remove all data (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            docker-compose down
            cd /root
            rm -rf /root/conduit
            echo "Conduit uninstalled."
        else
            echo "Uninstall cancelled."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|update|uninstall}"
        echo ""
        echo "Examples:"
        echo "  $0 start      - Start Conduit"
        echo "  $0 stop       - Stop Conduit"
        echo "  $0 restart    - Restart Conduit"
        echo "  $0 logs       - View logs"
        echo "  $0 status     - Check status"
        echo "  $0 update     - Update to latest version"
        echo "  $0 uninstall  - Remove Conduit completely"
        exit 1
        ;;
esac
EOF

chmod +x manage.sh

# Pull the latest image
echo "Pulling latest Conduit image..."
docker pull psiphoninc/conduit:latest

# Start Conduit
echo "Starting Conduit..."
docker-compose up -d

# Wait a moment for container to start
sleep 5

echo ""
echo "====================================="
echo "Installation Complete!"
echo "====================================="
echo ""
echo "Conduit is now running!"
echo ""
echo "Management commands:"
echo "  cd $PROJECT_DIR"
echo "  ./manage.sh start      - Start Conduit"
echo "  ./manage.sh stop       - Stop Conduit"
echo "  ./manage.sh restart    - Restart Conduit"
echo "  ./manage.sh logs       - View logs"
echo "  ./manage.sh status     - Check status"
echo "  ./manage.sh update     - Update to latest version"
echo "  ./manage.sh uninstall  - Remove Conduit completely"
echo ""
echo "Quick commands:"
echo "  cd /root/conduit && ./manage.sh logs    - View logs"
echo "  cd /root/conduit && ./manage.sh status  - Check status"
echo ""
echo "Checking Conduit status..."
cd "$PROJECT_DIR"
docker-compose ps
echo ""
echo "View logs with: cd /root/conduit && ./manage.sh logs"
echo ""
