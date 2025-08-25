#!/bin/bash
export DISPLAY=:0
Xvfb :0 -screen 0 1280x720x16 &
fluxbox &
x11vnc -forever -nopw -display :0 -rfbport 5900 &
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
emulator -avd test -noaudio -no-boot-anim -accel on -gpu swiftshader_indirect &
tail -f /dev/null
