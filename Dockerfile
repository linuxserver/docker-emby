FROM lsiobase/alpine:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# package versions
ARG FFMPEG_VER="3.4"
ARG MONO_VER="5.4.1.6"

# copy patches
COPY patches/ /tmp/patches/

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	alsa-lib-dev \
	autoconf \
	automake \
	binutils \
	bzip2-dev \
	cmake \
	curl \
	file \
	g++ \
	gcc \
	gettext \
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
	paxmark \
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
 echo "**** install runtime packages ****" && \
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
	python \
	soxr \
	speex \
	sqlite \
	unzip \
	v4l-utils-libs \
	x264 \
	x264-libs \
	x265 \
	xvidcore \
	zlib && \
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	libgdiplus && \
 echo "**** compile mono ****" && \
 mkdir -p \
	/tmp/mono-src && \
 curl -o \
 /tmp/mono.tar.bz2 -L \
	"https://download.mono-project.com/sources/mono/mono-${MONO_VER}.tar.bz2" && \
 tar xf \
 /tmp/mono.tar.bz2 -C \
	/tmp/mono-src --strip-components=1 && \
 cd /tmp/mono-src && \
 sed -i \
	's|$mono_libdir/||g' \
	/tmp/mono-src/data/config.in && \
 sed -i \
	'/exec "/ i\paxmark mr "$(readlink -f "$MONO_EXECUTABLE")"' \
	/tmp/mono-src/runtime/mono-wrapper.in && \
 export CFLAGS="$CFLAGS -Os -fno-strict-aliasing" && \
 ./configure \
	--disable-boehm \
	--disable-libraries \
	--infodir=/usr/share/info \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--prefix=/usr \
	--sysconfdir=/etc \
	--without-mcs-docs \
	--without-sigaltstack && \
 echo "**** attempt to set number of cores available for make to use ****" && \ 
 set -ex && \
 CPU_CORES=$( < /proc/cpuinfo grep -c processor ) || echo "failed cpu look up" && \
 if echo $CPU_CORES | grep -E  -q '^[0-9]+$'; then \
	: ;\
 if [ "$CPU_CORES" -gt 7 ]; then \
	CPU_CORES=$(( CPU_CORES  - 3 )); \
 elif [ "$CPU_CORES" -gt 5 ]; then \
	CPU_CORES=$(( CPU_CORES  - 2 )); \
 elif [ "$CPU_CORES" -gt 3 ]; then \
	CPU_CORES=$(( CPU_CORES  - 1 )); fi \
 else CPU_CORES="1"; fi && \
 make -j $CPU_CORES && \
 make install && \
 echo "**** install emby ****" && \
 mkdir -p \
	/usr/lib/emby && \
 EMBY_VER=$(curl -sX GET "https://api.github.com/repos/mediaBrowser/Emby/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o \
 /tmp/emby.zip -L \
	"https://github.com/MediaBrowser/Emby/releases/download/$EMBY_VER/Emby.Mono.zip" && \
 unzip -q /tmp/emby.zip -d /usr/lib/emby && \
 libMagicWand=$(find / -iname "libMagickWand-*.*.so.0" -exec basename \{} \;) && \
 libSqlite=$(find / -iname "libsqlite*.so.0" -exec basename \{} \;) && \
 IMAGEMAGIC_DLL_CONFIG=$(find /usr/lib/emby -iname "*ImageMagick*.dll.config") && \
 SQLITE_DLL_CONFIG=$(find /usr/lib/emby -iname "*sqlite3.dll.config") && \
 sed -i \
	s/libMagickWand-6.Q8.so/$libMagicWand/g \
	$IMAGEMAGIC_DLL_CONFIG && \
 sed -i \
	s/libsqlite3.so/$libSqlite/g \
	$SQLITE_DLL_CONFIG && \
 echo "**** compile ffmpeg ****" && \
 mkdir -p \
	/tmp/ffmpeg-src && \
 curl -o \
 /tmp/ffmpeg.tar.bz2 -L \
	"http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VER}.tar.bz2" && \
 tar xf \
 /tmp/ffmpeg.tar.bz2 -C \
	/tmp/ffmpeg-src --strip-components=1 && \
 cd /tmp/ffmpeg-src && \
 for i in /tmp/patches/ffmpeg/*.patch; do patch -p1 -i $i; done && \
 ./configure \
	--disable-debug \
	--disable-ffplay \
	--disable-indev=sndio \
	--disable-outdev=sndio \
	--disable-static \
	--disable-stripping \
	--enable-fontconfig \
	--enable-gpl \
	--enable-gray \
	--enable-libfreetype \
	--enable-libfribidi \
	--enable-libopenjpeg \
	--enable-libopus \
	--enable-librtmp \
	--enable-libsoxr \
	--enable-libspeex \
	--enable-libtheora \
	--enable-libv4l2 \
	--enable-libvorbis \
	--enable-libvpx \
	--enable-libwebp \
	--enable-libx264 \
	--enable-libx265 \
	--enable-libxvid \
	--enable-shared \
	--enable-vaapi \
	--enable-version3 \
	--prefix=/usr && \
 make -j $CPU_CORES && \
 set +ex && \
 make install && \
 echo "**** strip binaries ****" && \
 find /usr/lib \( -name "*.so" -o -name "*.so.*" \) -exec strip --strip-unneeded {} \; && \
 strip /usr/bin/ffmpeg /usr/bin/ffprobe  /usr/bin/ffserver /usr/bin/mono || true && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/* \
	/usr/lib/*.la \
	/usr/lib/libMonoSupportW.* \
	/usr/lib/mono/*/Mono.Security.Win32* \
	/usr/lib/mono/xbuild-frameworks/.NETPortable/v4.*

# add local files
COPY root/ /

# ports and volumes
# EXPOSE
VOLUME /config
