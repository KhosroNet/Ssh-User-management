#!/bin/bash

# تنظیمات متغیرها
WORKDIR="$HOME/conduit"
BINARY_URL="https://github.com/Psiphon-Inc/conduit/releases/download/v1.0.1/conduit-linux-amd64.tar.gz"

echo "--- شروع نصب Psiphon Conduit ---"

# ایجاد پوشه و ورود به آن
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# دانلود فایل اصلی (نسخه اصلاح شده)
echo "در حال دانلود فایل..."
wget -q -O conduit.tar.gz "$BINARY_URL"
if [ $? -ne 0 ]; then
    echo "خطا در دانلود! لطفاً اتصال اینترنت سرور را چک کنید."
    exit 1
fi

# استخراج و دسترسی
tar -xvf conduit.tar.gz
chmod +x conduit

# ساخت سرویس سیستمی برای اجرای همیشگی
echo "در حال تنظیم سرویس..."
sudo bash -c "cat <<EOT > /etc/systemd/system/conduit.service
[Unit]
Description=Psiphon Conduit Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$WORKDIR
# تنظیمات: ۱۰۰ کاربر همزمان و ۵۰ مگابیت پهنای باند
ExecStart=$WORKDIR/conduit start --max-clients 100 --bandwidth 50
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOT"

# فعال‌سازی و اجرا
sudo systemctl daemon-reload
sudo systemctl enable conduit
sudo systemctl start conduit

echo "------------------------------------------------"
echo "نصب با موفقیت تمام شد!"
echo "مشاهده وضعیت: sudo systemctl status conduit"
echo "مشاهده لاگ زنده: sudo journalctl -u conduit -f"
echo "------------------------------------------------"
