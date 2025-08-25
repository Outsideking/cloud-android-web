FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# ติดตั้ง dependency
RUN apt-get update && apt-get install -y \
    wget unzip curl git supervisor \
    qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager \
    libglu1-mesa openjdk-8-jdk \
    xfce4 xfce4-goodies x11vnc xvfb \
    novnc websockify \
    && rm -rf /var/lib/apt/lists/*

# ติดตั้ง Android SDK + Emulator
RUN mkdir -p /opt/android-sdk && cd /opt/android-sdk \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O cmdtools.zip \
    && unzip cmdtools.zip -d cmdline-tools && rm cmdtools.zip \
    && mkdir -p cmdline-tools/latest \
    && mv cmdline-tools/cmdline-tools/* cmdline-tools/latest/ \
    && yes | cmdline-tools/latest/bin/sdkmanager --sdk_root=/opt/android-sdk "platform-tools" "emulator" "system-images;android-30;google_apis;x86_64" "platforms;android-30"

# สร้าง Android Emulator AVD
RUN echo "no" | /opt/android-sdk/cmdline-tools/latest/bin/avdmanager create avd -n test -k "system-images;android-30;google_apis;x86_64" --device "pixel"

# คัดลอก start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# เปิดพอร์ต VNC (5901) + noVNC (6080)
EXPOSE 5901 6080

CMD ["/start.sh"]
