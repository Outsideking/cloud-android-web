#!/bin/bash
set -e

# --- CONFIG ---
TPSCLIP_REPO="https://github.com/Outsideking/tpsclip.git"
TPSCLIP_DIR=~/projects/tpsclip
SCANS_DIR=~/projects/scanzaclip/backend/services/tpsclip

echo "🚀 เริ่ม Auto Pull tpsclip + Build"

# 1) clone หรือ update tpsclip
if [ ! -d "$TPSCLIP_DIR" ]; then
    echo "📥 Clone tpsclip..."
    git clone $TPSCLIP_REPO $TPSCLIP_DIR
else
    echo "🔄 Update tpsclip..."
    cd $TPSCLIP_DIR && git pull origin main
fi

# 2) สร้างโฟลเดอร์ service ใน Scanzaclip
mkdir -p $SCANS_DIR

# 3) copy ไฟล์ที่จำเป็นเข้า Scanzaclip
cp -r $TPSCLIP_DIR/* $SCANS_DIR

echo "✅ โค้ด tpsclip ถูกรวมกับ Scanzaclip เรียบร้อย"

# 4) สร้าง Docker image สำหรับ tpsclip
cd $SCANS_DIR
docker build -t tpsclip-service .

echo "✅ Docker image tpsclip-service พร้อมใช้งาน"

# 5) update docker-compose
DOCKER_COMPOSE_FILE=~/projects/scanzaclip/docker-compose.override.yml

cat >> $DOCKER_COMPOSE_FILE <<EOL

  tpsclip-service:
    build: ./backend/services/tpsclip
    ports:
      - "6000:6000"
EOL

echo "✅ docker-compose.override.yml อัปเดตเรียบร้อย"

# 6) Restart Docker Compose
cd ~/projects/scanzaclip
docker compose down
docker compose up -d --build

echo "🎉 เสร็จสิ้น! tpsclip พร้อมใช้งานบน Scanzaclip"
