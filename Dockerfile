FROM lsiobase/alpine:3.6
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package versions
ARG FFMPEG_VER="3.3.3"
ARG FRAME_COMMIT="874cf94eeaf35aa267878f9983b280a00e7bed19"

# copy patches
COPY patches/ /tmp/patches/

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	alsa-lib-dev \
	autoconf \
	automake \
	bzip2-dev \
	cmake \
	coreutils \
	curl \
	file \
	g++ \
	gcc \
	git \
	gnutls-dev \
	jpeg-dev \
	lame-dev \
	lcms2-dev \
	libass-dev \
	libtheora-dev \
	libtool \
	libva-dev \
	libvorbis-dev \
	libvpx-dev \
	libwebp-dev \
	libxfixes-dev \
	make \
	openjpeg-dev \
	opus-dev \
	perl \
	rtmpdump-dev \
	sdl-dev \
	soxr-dev \
	speex-dev \
	tar \
	v4l-utils-dev \
	x264-dev \
	x265-dev \
	xvidcore-dev \
	yasm \
	zlib-dev && \
 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	frei0r-plugins-dev && \

# install runtime packages
 apk add --no-cache \
	alsa-lib \
	fontconfig \
	freetype \
	fribidi \
	imagemagick \
	libgomp \
	librtmp \
	libtheora \
	libva \
	libva-intel-driver \
	libvorbis \
	libvpx \
	libwebp \
	libxcb \
	openjpeg \
	opus \
	soxr \
	speex \
	sqlite \
	v4l-utils-libs \
	x264 \
	x264-libs \
	x265 \
	xvidcore && \
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	frei0r-plugins \
	mono && \

# compile opencore
 mkdir -p \
	/tmp/opencore-amr && \
 curl -o \
 /tmp/opencore-src.tar.gz -L \
	"https://sourceforge.net/projects/opencore-amr/files/latest/download" && \
 tar xf \
 /tmp/opencore-src.tar.gz -C \
	/tmp/opencore-amr --strip-components=1 && \
 cd /tmp/opencore-amr && \
 ./configure \
	--prefix=/usr && \
 make && \
 make install && \
 mkdir -p \
	/tmp/opencore-amrwbenc && \
 curl -o \
 /tmp/opencore-amrwbenc-src.tar.gz -L \
	"https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/vo-amrwbenc-0.1.3.tar.gz/download" && \
 tar xf \
 /tmp/opencore-amrwbenc-src.tar.gz -C \
	/tmp/opencore-amrwbenc && \
 ./configure \
	--prefix=/usr && \
 make && \
 make install && \
 libtool --finish /usr/lib && \

# compile vidstab
 git clone https://github.com/georgmartius/vid.stab /tmp/vidstap && \
 cd /tmp/vidstap && \
 cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/ && \
 make && \
 make install && \

# compile zimg
 git clone https://github.com/sekrit-twc/zimg /tmp/zimg && \
 cd /tmp/zimg && \
 ./autogen.sh && \
 ./configure \
	--prefix=/usr && \
 make && \
 make install && \

# compile ffmpeg
 mkdir -p /tmp/ffmpeg-src && \
 curl -o \
 /tmp/ffmpeg.tar.bz2 -L \
	"http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VER}.tar.bz2" && \
 tar xf \
 /tmp/ffmpeg.tar.bz2 -C \
	/tmp/ffmpeg-src --strip-components=1 && \
 cd /tmp/ffmpeg-src && \
 for i in /tmp/patches/*.patch; do patch -p1 -i $i; done && \
 ./configure \
	--disable-debug \
	--disable-ffplay \
	--disable-indev=sndio \
	--disable-outdev=sndio \
	--disable-static \
	--disable-stripping \
	--enable-fontconfig \
	--enable-frei0r \
	--enable-gpl \
	--enable-gray \
	--enable-libfreetype \
	--enable-libfribidi \
	--enable-libopencore-amrnb \
	--enable-libopencore-amrwb \
	--enable-libopenjpeg \
	--enable-libopus \
	--enable-librtmp \
	--enable-libsoxr \
	--enable-libspeex \
	--enable-libtheora \
	--enable-libv4l2 \
	--enable-libvidstab \
#	--enable-libvo-amrwbenc \
	--enable-libvorbis \
	--enable-libvpx \
	--enable-libwebp \
	--enable-libx264 \
	--enable-libx265 \
	--enable-libxvid \
	--enable-libzimg \
	--enable-shared \
	--enable-vaapi \
	--enable-version3 \
	--prefix=/usr && \
 make && \
 make install && \

# install referenceassemblies-pcl
 git clone https://github.com/directhex/xamarin-referenceassemblies-pcl /tmp/pcl && \
 cd /tmp/pcl && \
 git checkout $FRAME_COMMIT && \
 install -dm 755 /usr/lib/mono/xbuild-frameworks/.NETPortable/ && \
 cp -dr --no-preserve='ownership' v4.* /usr/lib/mono/xbuild-frameworks/.NETPortable/ && \

# compile emby
 mkdir -p \
	/tmp/emby-src/build && \
 EMBY_VER=$(curl -sX GET "https://api.github.com/repos/mediaBrowser/Emby/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
 /tmp/emby.tar.gz -L \
	"https://github.com/MediaBrowser/Emby/archive/$EMBY_VER.tar.gz" && \
 tar xf \
 /tmp/emby.tar.gz -C \
	/tmp/emby-src --strip-components=1 && \
 SQL_DLL=$(find / -name "*sqlite3.dll.config*") && \
 cd /tmp/emby-src && \
 libMagicWand=$(find / -iname "libMagickWand-7.*.so.0" -exec basename \{} \;) && \
 sed -i \
	s/libMagickWand-6.Q8.so/$libMagicWand/g \
	/tmp/emby-src/MediaBrowser.Server.Mono/ImageMagickSharp.dll.config && \
 libSqlite=$(find / -iname "libsqlite*.so.0" -exec basename \{} \;) && \
 SQLITE_DLL=$(find /tmp/emby-src -iname "*sqlite3.dll.config") && \
 sed -i \
	s/libsqlite3.so/$libSqlite/g \
	$SQLITE_DLL && \
 xbuild \
	/p:Configuration='Release Mono' \
	/p:Platform='Any CPU' \
	/p:OutputPath=/tmp/emby-src/build \
	/t:build MediaBrowser.Mono.sln && \
 mkdir -p \
	/usr/lib/emby && \
 cp -r /tmp/emby-src/build/* /usr/lib/emby/ && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/* \
	/usr/lib/mono/xbuild-frameworks/.NETPortable/v4.*

# add local files
COPY root/ /

# ports and volumes
# EXPOSE
VOLUME /config
