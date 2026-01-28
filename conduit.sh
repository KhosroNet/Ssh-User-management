#!/bin/bash

# Conduit Docker Installation Script
# This script sets up a Conduit node using Docker on Linux

set -e

echo "====================================="
echo "Conduit Docker Installation Script"
echo "====================================="
echo ""

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

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    
    # Install Docker Compose plugin
    apt-get update
    apt-get install -y docker-compose-plugin
    
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# Create project directory
PROJECT_DIR="/root/conduit"
echo ""
echo "Creating project directory at $PROJECT_DIR..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create data directory for persistent storage
echo "Creating data directory..."
mkdir -p data

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
        docker compose up -d
        echo "Conduit started. Use 'docker compose logs -f' to view logs."
        ;;
    stop)
        echo "Stopping Conduit..."
        docker compose down
        echo "Conduit stopped."
        ;;
    restart)
        echo "Restarting Conduit..."
        docker compose restart
        echo "Conduit restarted."
        ;;
    logs)
        docker compose logs -f
        ;;
    status)
        docker compose ps
        ;;
    update)
        echo "Updating Conduit..."
        docker compose pull
        docker compose up -d
        echo "Conduit updated."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|update}"
        echo ""
        echo "Examples:"
        echo "  $0 start    - Start Conduit"
        echo "  $0 stop     - Stop Conduit"
        echo "  $0 restart  - Restart Conduit"
        echo "  $0 logs     - View logs"
        echo "  $0 status   - Check status"
        echo "  $0 update   - Update to latest version"
        exit 1
        ;;
esac
EOF

chmod +x manage.sh

# Start Conduit
echo "Starting Conduit for the first time..."
docker compose up -d

echo ""
echo "====================================="
echo "Installation Complete!"
echo "====================================="
echo ""
echo "Project directory: $PROJECT_DIR"
echo ""
echo "Conduit is now running!"
echo ""
echo "Management commands:"
echo "  cd $PROJECT_DIR"
echo "  ./manage.sh start    - Start Conduit"
echo "  ./manage.sh stop     - Stop Conduit"
echo "  ./manage.sh restart  - Restart Conduit"
echo "  ./manage.sh logs     - View logs"
echo "  ./manage.sh status   - Check status"
echo "  ./manage.sh update   - Update to latest version"
echo ""
echo "Or use Docker Compose directly:"
echo "  cd $PROJECT_DIR"
echo "  docker compose up -d       - Start in background"
echo "  docker compose down        - Stop"
echo "  docker compose logs -f     - View logs"
echo ""
echo "Data directory: $PROJECT_DIR/data"
echo "Your node key is saved here and will persist across restarts."
echo ""
echo "To view logs now, run:"
echo "  cd $PROJECT_DIR && docker compose logs -f"
echo ""
