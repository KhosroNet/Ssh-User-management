#!/bin/bash

# رنگ‌ها برای خروجی
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- Starting Conduit Node Installation (Official CLI Method) ---${NC}"

# ۱. نصب پیش‌نیازهای اولیه
echo -e "${GREEN}[1/5] Installing wget and tar...${NC}"
sudo apt update && sudo apt install -y wget tar

# ۲. ایجاد پوشه پروژه و دایرکتوری داده
# دایرکتوری داده برای حفظ کلید شناسایی (Identity Key) و اعتبار نود حیاتی است
echo -e "${GREEN}[2/5] Setting up directory at ~/conduit-node...${NC}"
mkdir -p ~/conduit-node/data
cd ~/conduit-node

# ۳. دانلود نسخه رسمی مخصوص لینوکس (v1.0.5)
# این نسخه نیاز به فایل کانفیگ خارجی ندارد
echo -e "${GREEN}[3/5] Downloading official Conduit binary...${NC}"
wget https://github.com/Psiphon-Inc/conduit/releases/download/v1.0.5/conduit-linux-amd64.tar.gz
tar -xvf conduit-linux-amd64.tar.gz
chmod +x conduit

# ۴. ایجاد سرویس سیستمی برای اجرا در پس‌زمینه
echo -e "${GREEN}[4/5] Creating systemd service...${NC}"
sudo cat <<EOF > /etc/systemd/system/conduit.service
[Unit]
Description=Psiphon Conduit Node
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$(pwd)
# تنظیمات طبق مقادیر پیش‌فرض مستندات: پهنای باند ۴۰ و ۵۰ کاربر
ExecStart=$(pwd)/conduit start --data-dir $(pwd)/data --bandwidth 40 --max-clients 50
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# ۵. فعال‌سازی و اجرای سرویس
echo -e "${GREEN}[5/5] Starting Conduit service...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable conduit
sudo systemctl start conduit

echo -e "${BLUE}----------------------------------------${NC}"
echo -e "${GREEN}Installation Successful! 🚀${NC}"
echo -e "Node key saved in: ${BLUE}$(pwd)/data/conduit_key.json${NC}"
echo -e "To view live logs, run: ${BLUE}journalctl -u conduit -f${NC}"
echo -e "${BLUE}----------------------------------------${NC}"
