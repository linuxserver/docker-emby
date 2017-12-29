FROM lsiobase/alpine:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
ARG EMBY_VER
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs,thelamer"
# base lang
ENV LANG=C.UTF-8

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.26-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    echo "**** Install Libs and Build deps ****" && \
    apk add --no-cache imagemagick-dev sqlite-dev && \
    apk add --no-cache --virtual=.build-dependencies curl wget ca-certificates && \
    wget -q \
      "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
      -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    echo "**** Install GlibC Credit https://github.com/frol ****" && \
    wget -q \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
      "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    echo "**** Install Mono from Arch Testing repo ****" && \
    wget -q "https://www.archlinux.org/packages/testing/x86_64/mono/download/" -O "/tmp/mono.pkg.tar.xz" && \
    tar -xJf "/tmp/mono.pkg.tar.xz" && \
    echo "**** Install Pre-Built FFmpeg ****" && \
    wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz && \
    tar xf ffmpeg-release-64bit-static.tar.xz && \
    mv ffmpeg-*/ffmpeg ffmpeg-*/ffserver ffmpeg-*/ffprobe /usr/bin/ && \
    cert-sync /etc/ssl/certs/ca-certificates.crt && \
    echo "**** Install Emby by version tag ****" && \
    mkdir -p \
      /usr/lib/emby && \
    curl -s -o \
    /tmp/emby.zip -L \
      "https://github.com/MediaBrowser/Emby/releases/download/$EMBY_VER/Emby.Mono.zip" && \
    unzip -q /tmp/emby.zip -d /usr/lib/emby && \
    echo "**** Cleanup ****" && \
    apk del .build-dependencies && \
    apk del glibc-i18n && \
    rm -Rf \
      /usr/lib/*.la \
      /usr/lib/libMonoSupportW.* \
      /usr/lib/mono/*/Mono.Security.Win32* \
      /usr/lib/mono/xbuild-frameworks/.NETPortable/v4.* \
      "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
      "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" \
      "/etc/apk/keys/sgerrand.rsa.pub" \
      "/root/.wget-hsts" \
      ffmpeg* \
      /tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /transcode
EXPOSE 8096
EXPOSE 8920

