# Base image Ubuntu 20.04
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# ติดตั้ง dependencies
RUN apt-get update && apt-get install -y \
    wget unzip openjdk-11-jdk \
    libgl1-mesa-dev libx11-6 xvfb x11vnc fluxbox \
    novnc websockify curl git && \
    rm -rf /var/lib/apt/lists/*

# ติดตั้ง Android Command Line Tools
RUN mkdir -p /opt/android-sdk/cmdline-tools && cd /opt \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d android-sdk/cmdline-tools \
    && rm cmdline-tools.zip

ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Accept licenses & install emulator + system image
RUN yes | sdkmanager --licenses || true
RUN sdkmanager "platform-tools" "platforms;android-30" "system-images;android-30;google_apis;x86_64" "emulator"

# สร้าง AVD ชื่อ test
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-30;google_apis;x86_64" --device "pixel"

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# เปิด port สำหรับ noVNC
EXPOSE 6080

# Run start.sh
CMD ["/start.sh"]
