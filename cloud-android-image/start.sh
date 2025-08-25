#!/bin/bash
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH

# เริ่ม X virtual framebuffer
Xvfb :0 -screen 0 1280x720x24 &

# รัน Android Emulator
$ANDROID_SDK_ROOT/emulator/emulator -avd test -noaudio -no-boot-anim -gpu swiftshader_indirect -qemu -vnc :1 &

# รัน x11vnc บน :0
x11vnc -display :0 -nopw -listen 0.0.0.0 -xkb -forever -rfbport 5901 &

# รัน noVNC server (websocket → VNC)
websockify --web=/usr/share/novnc/ 6080 localhost:5901
