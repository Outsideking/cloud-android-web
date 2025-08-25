FROM dorowu/ubuntu-desktop-lxde-vnc:focal

RUN apt-get update && apt-get install -y \
    android-tools-adb \
    android-sdk \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6080
CMD ["/start.sh"]
