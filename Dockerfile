FROM openjdk:17-jdk-slim
ARG SAPJVM_VERSION=8.1.106
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Install GTK and X11 dependencies for Eclipse UI
RUN apt-get update && \
    apt-get install -y wget net-tools curl unzip libxext6 libxrender1 libxtst6 libxi6 libgtk-3-0 libwebkit2gtk-4.0-37 dbus-x11 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
# Install SAPJVM8
WORKDIR /opt
RUN curl --cookie eula_3_2_agreed=tools.hana.ondemand.com/developer-license-3_2.txt "https://tools.hana.ondemand.com/additional/sapjvm-${SAPJVM_VERSION}-linux-x64.zip" --output sapjvm8-linux-x64.zip \
 && unzip sapjvm8-linux-x64.zip \
 && rm sapjvm8-linux-x64.zip \
 && echo "export JAVA_HOME=/opt/sapjvm_8; export PATH=\${PATH}:/opt/sapjvm_8/bin" > /etc/profile.d/javahome.sh
ENV ECLIPSE_HOME=/opt/eclipse
ENV WORKSPACE=/workspace
WORKDIR /tmp
# Use a direct mirror link for Eclipse 2025-09 tarball
RUN wget -O eclipse.tar.gz "https://ftp.snt.utwente.nl/pub/software/eclipse/technology/epp/downloads/release/2025-09/R/eclipse-committers-2025-09-R-linux-gtk-x86_64.tar.gz" && \
    mkdir -p $ECLIPSE_HOME && \
    tar -xzf eclipse.tar.gz -C /opt && \
    rm eclipse.tar.gz
# Create a developer user matching your own UID/GID environment variables
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID developer && \
    useradd -m -u $USER_ID -g developer developer && \
    chown -R developer:developer $ECLIPSE_HOME
# Install dependencies for Chrome
RUN apt-get update && apt-get install -y \
    gnupg \
    apt-transport-https \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*
# Add Google’s signing key & repo
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list
# Install Chrome stable
RUN apt-get update && apt-get install -y google-chrome-stable \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get -y upgrade
# Install matching ChromeDriver dynamically into /usr/bin
RUN CHROME_MAJOR_VERSION=$(google-chrome --version | sed -E 's/Google Chrome ([0-9]+)\..*/\1/') && \
    DRIVER_VERSION=$(wget -qO- https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_${CHROME_MAJOR_VERSION}) && \
    wget -q "https://storage.googleapis.com/chrome-for-testing-public/${DRIVER_VERSION}/linux64/chromedriver-linux64.zip" && \
    unzip chromedriver-linux64.zip && \
    mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver && \
    rm -rf chromedriver-linux64.zip chromedriver-linux64
USER developer
WORKDIR $ECLIPSE_HOME
ENTRYPOINT ["/entrypoint.sh"]
