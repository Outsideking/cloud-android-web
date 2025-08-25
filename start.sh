#!/bin/bash
set -e

export DISPLAY=:0

# Start X virtual framebuffer
Xvfb :0 -screen 0 1280x720x16 &

# Start window manager
fluxbox &

# Start VNC server
x11vnc -forever -nopw -display :0 -rfbport 5900 &

# Start noVNC web server
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &

# Start Android emulator
emulator -avd test -noaudio -no-boot-anim -accel on -gpu swiftshader_indirect &

# Keep container running
tail -f /dev/null
