#!/bin/bash

set -e

echo "====================================="
echo "Conduit Docker Installation Script"
echo "====================================="
echo ""

PROJECT_DIR="/root/conduit"

# حذف نصب قدیمی
if [ -d "$PROJECT_DIR" ]; then
    echo "Removing old installation..."
    cd "$PROJECT_DIR"
    docker-compose down 2>/dev/null || true
    
    if [ -d "data" ]; then
        BACKUP_DIR="/root/conduit_backup_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        cp -r data "$BACKUP_DIR/"
        echo "Data backed up to: $BACKUP_DIR"
    fi
    
    cd /root
    rm -rf "$PROJECT_DIR"
    echo "Old installation removed."
fi

# نصب docker-compose اگر نباشه
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed."
fi

# نصب git اگر نباشه
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apt-get update -qq
    apt-get install -y git
fi

# کلون کردن ریپوزیتوری
echo "Cloning Conduit repository..."
git clone https://github.com/Psiphon-Inc/conduit.git "$PROJECT_DIR"
cd "$PROJECT_DIR"

# ساخت دایرکتوری data
mkdir -p data

# بازگردانی بکاپ
LATEST_BACKUP=$(ls -td /root/conduit_backup_* 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ] && [ -d "$LATEST_BACKUP/data" ]; then
    echo "Restoring backup..."
    cp -r "$LATEST_BACKUP/data/"* data/ 2>/dev/null || true
    echo "Backup restored."
fi

# ساخت Dockerfile
echo "Creating Dockerfile..."
cat > Dockerfile << 'EOFDOCKER'
FROM golang:1.24-alpine AS builder

WORKDIR /build

RUN apk add --no-cache git make bash

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN make build || go build -o dist/conduit ./cmd/conduit

FROM alpine:latest

RUN apk add --no-cache ca-certificates

WORKDIR /app

COPY --from=builder /build/dist/conduit /app/conduit

RUN mkdir -p /data

EXPOSE 8080

ENTRYPOINT ["/app/conduit"]
CMD ["start", "--data-dir", "/data", "-v"]
EOFDOCKER

# ساخت docker-compose.yml
echo "Creating docker-compose.yml..."
cat > docker-compose.yml << 'EOFCOMPOSE'
version: '3.8'

services:
  conduit:
    build: .
    container_name: conduit
    restart: unless-stopped
    volumes:
      - ./data:/data
    ports:
      - "8080:8080"
    command: start --data-dir /data -v
EOFCOMPOSE

# ساخت manage.sh
cat > manage.sh << 'EOFMANAGE'
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
    rebuild)
        echo "Rebuilding Conduit..."
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
        echo "Conduit rebuilt and started."
        ;;
    update)
        echo "Updating Conduit..."
        git pull
        docker-compose down
        docker-compose build
        docker-compose up -d
        echo "Conduit updated."
        ;;
    uninstall)
        echo "Uninstalling Conduit..."
        read -p "Remove all data? (y/n): " confirm
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
        echo "Usage: $0 {start|stop|restart|logs|status|rebuild|update|uninstall}"
        echo ""
        echo "Commands:"
        echo "  start     - Start Conduit"
        echo "  stop      - Stop Conduit"
        echo "  restart   - Restart Conduit"
        echo "  logs      - View logs (Ctrl+C to exit)"
        echo "  status    - Check status"
        echo "  rebuild   - Rebuild and restart"
        echo "  update    - Pull latest code and rebuild"
        echo "  uninstall - Remove Conduit"
        exit 1
        ;;
esac
EOFMANAGE

chmod +x manage.sh

# بیلد و اجرای Conduit
echo ""
echo "Building Conduit (this may take a few minutes)..."
docker-compose build

echo ""
echo "Starting Conduit..."
docker-compose up -d

sleep 5

echo ""
echo "====================================="
echo "Installation Complete!"
echo "====================================="
echo ""
echo "Conduit is now running!"
echo ""
echo "Management commands:"
echo "  cd /root/conduit && ./manage.sh start     - Start"
echo "  cd /root/conduit && ./manage.sh stop      - Stop"
echo "  cd /root/conduit && ./manage.sh restart   - Restart"
echo "  cd /root/conduit && ./manage.sh logs      - View logs"
echo "  cd /root/conduit && ./manage.sh status    - Status"
echo "  cd /root/conduit && ./manage.sh update    - Update"
echo ""
echo "Checking status..."
docker-compose ps
echo ""
echo "View logs with: cd /root/conduit && ./manage.sh logs"
echo ""
