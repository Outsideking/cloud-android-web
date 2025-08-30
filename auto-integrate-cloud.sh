#!/bin/bash
set -e

# --- CONFIG ---
SCANZACLIP_DIR=~/projects/scanzaclip
CLOUD_ANDROID_REPO=https://github.com/Outsideking/cloud-android-web.git
CLOUD_ANDROID_DIR=$SCANZACLIP_DIR/backend/services/cloud-android-web

echo "🚀 เริ่ม Auto Integration Scanzaclip + Cloud Android Web"

# 1. clone หรือ update cloud-android-web
if [ ! -d "$CLOUD_ANDROID_DIR" ]; then
  echo "📥 กำลัง clone cloud-android-web..."
  git clone $CLOUD_ANDROID_REPO $CLOUD_ANDROID_DIR
else
  echo "🔄 อัปเดต cloud-android-web..."
  cd $CLOUD_ANDROID_DIR && git pull origin main
fi

# 2. สร้าง docker-compose override
cd $SCANZACLIP_DIR

cat > docker-compose.override.yml <<EOL
version: "3.8"
services:
  cloud-android-web:
    build: ./backend/services/cloud-android-web
    ports:
      - "5000:5000"
    environment:
      - PAYPAL_CLIENT_ID=\${PAYPAL_CLIENT_ID}
      - PAYPAL_CLIENT_SECRET=\${PAYPAL_CLIENT_SECRET}
      - OPN_SECRET_KEY=\${OPN_SECRET_KEY}
EOL

echo "✅ docker-compose.override.yml ถูกสร้างแล้ว"

# 3. เชื่อม Frontend Scanzaclip
FRONTEND_DIR=$SCANZACLIP_DIR/frontend/cloud-android
mkdir -p $FRONTEND_DIR
cat > $FRONTEND_DIR/index.html <<EOL
<!DOCTYPE html>
<html>
<head>
  <title>Cloud Android</title>
</head>
<body>
  <h1>Cloud Android Emulator</h1>
  <iframe src="http://localhost:5000" width="100%" height="800px"></iframe>
</body>
</html>
EOL

echo "✅ เพิ่มหน้า Frontend Cloud Android แล้ว"

# 4. restart docker-compose
docker compose down
docker compose up -d --build

echo "🎉 เสร็จสิ้น! Cloud Android Web ถูกรวมกับ Scanzaclip แล้ว"
echo "🌍 Dashboard: http://localhost:4000/cloud-android"
echo "📱 Emulator: http://localhost:5000"
