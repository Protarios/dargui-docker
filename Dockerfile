FROM ich777/novnc-baseimage
MAINTAINER Zerginator

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-dirsyncpro"

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL maintainer="zerginator"
ENV DAR_PREFIX /usr/local/dar
ENV PATH $PATH:$DAR_PREFIX/bin
RUN mkdir -p "$DAR_PREFIX"
WORKDIR $DAR_PREFIX

RUN export TZ=Europe/Rome && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	echo "yes" | apt-get -y install --no-install-recommends cifs-utils sudo curl curlftpfs davfs2 cryfs fonts-takao && \
	echo "ko_KR.UTF-8 UTF-8" >> /etc/locale.gen && \ 
	echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "DarGui - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/*

ENV DATA_DIR=/dargui
ENV REMOTE_DIR="192.168.1.1"
ENV REMOTE_TYPE="smb"
ENV REMOTE_USER=""
ENV REMOTE_PWD=""
ENV CRYFS=""
ENV CRYFS_PWD=""
ENV CRYFS_BLOCKSIZE=262144
ENV CRYFS_EXTRA_PARAMETERS=""
ENV RUNTIME_NAME="basicjre"
ENV DL_URL=""
ENV CMD_MODE=""
ENV CMD_FILE=""
ENV CUSTOM_RES_W=1024
ENV CUSTOM_RES_H=768
ENV CUSTOM_DEPTH=16
ENV TURBOVNC_PARAMS="-securitytypes none"
ENV NOVNC_PORT=8080
ENV RFB_PORT=5900
ENV START_PARAMS=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="dargui"

# install dar runtime dependencies
# http://dar.linux.free.fr/doc/from_sources.html#requirements
RUN apt-get update \
	&& apt-get install -y --force-yes --no-install-recommends \
		zlib1g \
		bzip2 \
		liblzma5 \
		libgcrypt20 \
		liblzo2-2 \
		libgtk2.0-0 \
		xterm \
	&& rm -r /var/lib/apt/lists/*

ENV DAR_VERSION 2.7.14
ENV DAR_URL http://netcologne.dl.sourceforge.net/project/dar/dar/$DAR_VERSION/dar-$DAR_VERSION.tar.gz

RUN buildDeps=' \
		zlib1g-dev \
		libbz2-dev \
		liblzma-dev \
		libgcrypt20-dev \
		liblzo2-dev \
		curl \
		gcc \
		g++ \
		binutils \
		make \
	' \
	set -x \
	&& apt-get update \
	&& apt-get install -y $buildDeps \
	&& rm -r /var/lib/apt/lists/* \
	&& curl -SL "$DAR_URL" -o dar.tar.gz \
	&& mkdir -p src/dar \
	&& tar -xvf dar.tar.gz -C src/dar --strip-components=1 \
	&& rm dar.tar.gz* \
	&& cd src/dar \
	&& ./configure --enable-mode=64 \
	&& make -j"$(nproc)" \
	&& make install-strip \
	&& cd ../../ \
	&& rm -r src/dar \
	&& apt-get purge -y --auto-remove $buildDeps

ENV DARGUI_VERSION 1.3
ENV DARGUI_URL https://sourceforge.net/projects/dargui/files/dargui/$DARGUI_VERSION/dargui-$DARGUI_VERSION-bin.tar.gz/download

RUN buildDeps=' \
		zlib1g-dev \
		libbz2-dev \
		liblzma-dev \
		libgcrypt20-dev \
		liblzo2-dev \
		curl \
		gcc \
		g++ \
		binutils \
		make \
	' \
	set -x \
	&& apt-get update \
	&& apt-get install -y $buildDeps \
	&& rm -r /var/lib/apt/lists/* \
	&& curl -SL "$DARGUI_URL" -o dargui.tar.gz \
	&& mkdir -p src/dargui \
	&& tar -xvf dargui.tar.gz -C src/dargui --strip-components=1 \
	&& rm dargui.tar.gz* \
	&& cd src/dargui \
	&& ./install.sh \
	&& apt-get purge -y --auto-remove $buildDeps

RUN mkdir /backupsource && mkdir /backupsink && mkdir /DAR && mkdir /config

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048 && \
	echo "$USER ALL=(root) NOPASSWD:/bin/mount" >> /etc/sudoers

VOLUME /config
VOLUME /backupsource
VOLUME /DAR
VOLUME /backupsink

ADD /scripts/ /opt/scripts/
COPY /icons/* /usr/share/novnc/app/images/icons/
COPY /conf/ /etc/.fluxbox/
RUN chmod -R 770 /opt/scripts/ && \
	chown -R ${UID}:${GID} /mnt && \
	chmod -R 770 /mnt

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
