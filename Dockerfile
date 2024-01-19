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
  echo "**** install emby ****" && \
  mkdir -p \
    /app/emby \
    /tmp/emby && \
  if [ -z ${EMBY_RELEASE+x} ]; then \
    EMBY_RELEASE=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases \
    | jq -r 'first(.[] | select(.prerelease==true )) | .tag_name'); \
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

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
