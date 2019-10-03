FROM lsiobase/ubuntu:bionic as buildstage

# build args
ARG EMBY_RELEASE
ENV DEBIAN_FRONTEND="noninteractive" 

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	jq && \
 echo "**** install emby ****" && \
 mkdir -p \
	/app/emby && \
 if [ -z ${EMBY_RELEASE+x} ]; then \
	EMBY_RELEASE=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases \
	| jq -r 'first(.[] | select(.prerelease = "true" )) | .tag_name'); \
 fi && \
 curl -o \
	/tmp/emby.deb -L \
	"https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_RELEASE}/emby-server-deb_${EMBY_RELEASE}_amd64.deb" && \
 cd /tmp && \
 dpkg -x emby.deb \
	/tmp && \
 mv -t \
	/app/emby/ \
	/tmp/opt/emby-server/system/* \
	/tmp/opt/emby-server/lib/samba/* \
	/tmp/opt/emby-server/lib/* \
	/tmp/opt/emby-server/bin/ff* \
	/tmp/opt/emby-server/etc

# runtime stage
FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# add needed nvidia environment variables for https://github.com/NVIDIA/nvidia-docker
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# add local files
COPY --from=buildstage /app/emby /app/emby
COPY root/ /

# ports and volumes
EXPOSE 8096 8920
VOLUME /config /transcode
