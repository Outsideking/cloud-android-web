FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget unzip openjdk-11-jdk x11vnc xvfb novnc websockify qemu-kvm

# Android SDK
RUN mkdir -p /android-sdk && cd /android-sdk \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip commandlinetools-linux-9477386_latest.zip \
    && rm *.zip

ENV ANDROID_SDK_ROOT=/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin:$ANDROID_SDK_ROOT/platform-tools

RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "emulator" "system-images;android-33;google_apis;x86_64"
RUN echo "no" | avdmanager create avd -n cloudandroid -k "system-images;android-33;google_apis;x86_64"

EXPOSE 5901 6080

CMD Xvfb :0 -screen 0 1280x720x16 & \
    emulator -avd cloudandroid -noaudio -no-boot-anim -gpu swiftshader_indirect -no-window & \
    x11vnc -display :0 -forever -nopw -shared -rfbport 5901 & \
    websockify -D 6080 localhost:5901 && tail -f /dev/null
