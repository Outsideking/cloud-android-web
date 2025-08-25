FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y wget unzip openjdk-11-jdk libgl1-mesa-dev libx11-6 xvfb x11vnc fluxbox novnc websockify && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/android-sdk && cd /opt \
 && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O cmd.zip \
 && unzip cmd.zip -d android-sdk && rm cmd.zip
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$PATH
RUN yes | sdkmanager --licenses || true
RUN sdkmanager "platform-tools" "platforms;android-30" "system-images;android-30;google_apis;x86_64" "emulator"
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-30;google_apis;x86_64" --device "pixel"
COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 6080
CMD ["/start.sh"]
