FROM openjdk:17-jdk-slim

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Install GTK and X11 dependencies for Eclipse UI
RUN apt-get update && \
    apt-get install -y wget libxext6 libxrender1 libxtst6 libxi6 libgtk-3-0 libwebkit2gtk-4.0-37 dbus-x11 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV ECLIPSE_HOME=/opt/eclipse
ENV WORKSPACE=/workspace

WORKDIR /tmp

# Use a direct mirror link for Eclipse 2025-06 tarball
RUN wget -O eclipse.tar.gz "https://mirror.csclub.uwaterloo.ca/eclipse/technology/epp/downloads/release/2025-06/R/eclipse-committers-2025-06-R-linux-gtk-x86_64.tar.gz" && \
    mkdir -p $ECLIPSE_HOME && \
    tar -xzf eclipse.tar.gz -C /opt && \
    rm eclipse.tar.gz

# Create a developer user matching your own UID/GID environment variables
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g $GROUP_ID developer && \
    useradd -m -u $USER_ID -g developer developer && \
    chown -R developer:developer $ECLIPSE_HOME

USER developer

WORKDIR $ECLIPSE_HOME
ENTRYPOINT ["/entrypoint.sh"]
