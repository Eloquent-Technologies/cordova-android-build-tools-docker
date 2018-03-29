FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN dpkg --add-architecture i386 && \
	apt-get update -y && \
	apt-get install -y libncurses5:i386 libc6:i386 libstdc++6:i386 lib32gcc1 lib32ncurses5 lib32z1 zlib1g:i386  && \
	apt-get install -y --no-install-recommends openjdk-8-jdk && \
	apt-get install -y git wget zip nodejs && \
	apt-get install -y qt5-default

# download and install Gradle
ENV GRADLE_VERSION 4.6
RUN cd /opt && \
	wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
	unzip gradle*.zip && \
	ls -d */ | sed 's/\/*$//g' | xargs -I{} mv {} gradle && \
	rm gradle*.zip

# download and install Android SDK
ENV ANDROID_SDK_VERSION 3859397
RUN mkdir -p /opt/android-sdk && cd /opt/android-sdk && \
	wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
	unzip *tools*linux*.zip && \
	rm *tools*linux*.zip

# set environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV GRADLE_HOME /opt/gradle
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap

# accept the license agreements of the SDK components
ADD license_accepter.sh /opt/
RUN /opt/license_accepter.sh $ANDROID_HOME

# install builds tools
ENV ANDROID_BUILD_TOOLS_VERSION "build-tools;26.0.3"
RUN $ANDROID_HOME/tools/bin/sdkmanager ${ANDROID_BUILD_TOOLS_VERSION}

# download and install cordova
RUN npm install -g cordova
RUN cordova telemetry off 

RUN apt-get install -y locales && rm -rf /var/lib/apt/lists/* && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8
