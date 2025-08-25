## 🔧 คำอธิบายการแก้ไข
- เพิ่ม GitHub Actions workflow (`.github/workflows/autofix.yml`) สำหรับ auto-fix
- workflow จะสร้าง/แก้ไขไฟล์หลัก:
  - `cloud-android/Dockerfile`
  - `cloud-android/start.sh`
  - `docker-compose.yml`

## 🚀 วิธีใช้งาน
1. Merge PR นี้ เข้า `main`
2. ไปที่แท็บ **Actions** → เลือก workflow `Auto Fix Cloud Android`
3. กด **Run workflow**
4. ระบบจะ commit ไฟล์แก้ไขอัตโนมัติ เข้าสู่ branch `main`

## ✅ ผลลัพธ์
- ได้ Dockerfile ที่สามารถรัน Android Emulator + VNC + noVNC ได้
- start.sh สั่งรัน emulator และ VNC อัตโนมัติ
- docker-compose.yml รวม backend, frontend, android, mongo

---
> ⚠️ หมายเหตุ: ถ้าต้องการปรับแต่ง emulator (เช่น ขนาดหน้าจอ, SDK version) สามารถแก้ไขใน `cloud-android/Dockerfile` ได้เลย
