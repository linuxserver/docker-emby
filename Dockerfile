# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG EMBY_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

ARG DEBIAN_FRONTEND="noninteractive"

# add needed nvidia environment variables for https://github.com/NVIDIA/nvidia-docker
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# install packages
RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    autoconf \
    libtool \
    git \
    build-essential \
    libargtable2-dev \
    libavformat-dev \
    libsdl1.2-dev
    
RUN \
  echo "**** install emby ****" && \
  mkdir -p \
    /app/emby \
    /tmp/emby && \
  if [ -z ${EMBY_RELEASE+x} ]; then \
    EMBY_RELEASE=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest \
    | jq -r '. | .tag_name'); \
  fi && \
  curl -o \
    /tmp/emby.deb -L \
    "https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_RELEASE}/emby-server-deb_${EMBY_RELEASE}_amd64.deb" && \
  dpkg-deb -xv /tmp/emby.deb /tmp/emby/ && \
  mv -t \
    /app/emby/ \
    /tmp/emby/opt/emby-server/* && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*
    
RUN \
  echo "***** compile comskip ****" && \
  git clone https://github.com/erikkaashoek/Comskip /tmp/comskip && \
  cd /tmp/comskip && \
  ./autogen.sh && \
  ./configure \
    --bindir=/usr/bin \
    --sysconfdir=/config/comskip && \
  make -j 2 && \
  make DESTDIR=/tmp/comskip-build install
  
# copy local files and buildstage artifacts
COPY --from=buildstage /tmp/comskip-build/usr/ /usr/

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
