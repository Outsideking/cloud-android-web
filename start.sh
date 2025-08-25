#!/bin/bash
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH

# เริ่ม X virtual framebuffer
Xvfb :0 -screen 0 1280x720x24 &

# รัน Android Emulator แบบ software-only (ไม่มี KVM)
$ANDROID_SDK_ROOT/emulator/emulator -avd test \
  -no-window -noaudio -no-boot-anim \
  -gpu swiftshader_indirect -no-snapshot -noaccel \
  -qemu -vnc :1 &

# รัน x11vnc
x11vnc -display :0 -nopw -listen 0.0.0.0 -xkb -forever -rfbport 5901 &

# รัน noVNC
websockify --web=/usr/share/novnc/ 6080 localhost:5901
