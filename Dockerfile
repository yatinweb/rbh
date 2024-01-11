FROM ubuntu:18.04
LABEL MAINTAINER Yatin Patel

RUN apt-get update
RUN apt-get -y install openjdk-8-jdk wget curl unzip xz-utils python build-essential ssh git


# Setup certificates in openjdk-8
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# download and install Gradle
# https://services.gradle.org/distributions/
ARG GRADLE_VERSION=7.4.2
ARG GRADLE_DIST=all
RUN cd /opt && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-${GRADLE_DIST}.zip && \
    unzip gradle*.zip && \
    ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
    rm gradle*.zip

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# download and install Android SDK
RUN mkdir -p /opt/android/sdk && mkdir .android && \
    cd /opt/android/sdk && \
    curl -o sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
    unzip sdk.zip && \
    rm sdk.zip

RUN yes | /opt/android/sdk/tools/bin/sdkmanager --licenses
RUN /opt/android/sdk/tools/bin/sdkmanager --update > /dev/null
RUN /opt/android/sdk/tools/bin/sdkmanager platform-tools > /dev/null
RUN /opt/android/sdk/tools/bin/sdkmanager tools > /dev/null
#RUN /opt/android/sdk/tools/bin/sdkmanager emulator > /dev/null
RUN /opt/android/sdk/tools/bin/sdkmanager "extras;android;m2repository" > /dev/null
RUN /opt/android/sdk/tools/bin/sdkmanager "extras;google;m2repository" > /dev/null
RUN /opt/android/sdk/tools/bin/sdkmanager "extras;google;google_play_services" > /dev/null
RUN /opt/android/sdk/tools/bin/sdkmanager "build-tools;32.0.0" > /dev/null
RUN /opt/android/sdk/tools/bin/sdkmanager "platforms;android-32" > /dev/null

ENV ANDROID_SDK_ROOT /opt/android/sdk
ENV BUILD_TOOLS_VER 32.0.0

# set the environment variables
ENV GRADLE_HOME /opt/gradle
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/build-tools/${BUILD_TOOLS_VER}

# Install chrome and dependencies (for puppeteer)
RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb

RUN npm install -g ionic && npm install i -g cordova

WORKDIR /app
