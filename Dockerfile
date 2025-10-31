# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG FIREFOX_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Firefox \
    NO_GAMEPAD=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/firefox-logo.png && \
  echo "**** install packages ****" && \
  apt-key adv \
    --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys 5301FA4FD93244FBC6F6149982BB6851C64F6880 && \
  echo \
    "deb https://ppa.launchpadcontent.net/xtradeb/apps/ubuntu noble main" > \
    /etc/apt/sources.list.d/xtradeb.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    firefox \
    ^firefox-locale \
    ffmpeg \
    pulseaudio-utils \
    netcat-openbsd && \
  echo "**** install firefox extensions ****" && \
  mkdir -p /usr/lib/firefox/distribution/extensions && \
  curl -L -o '/usr/lib/firefox/distribution/extensions/uBlock0@raymondhill.net.xpi' https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi && \
  curl -L -o '/usr/lib/firefox/distribution/extensions/sponsorBlocker@ajay.app.xpi' https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi && \
  echo "**** default firefox settings ****" && \
  FIREFOX_SETTING="/usr/lib/firefox/browser/defaults/preferences/firefox.js" && \
  echo 'pref("datareporting.policy.firstRunURL", "");' > ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.policy.dataSubmissionEnabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.healthreport.service.enabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.healthreport.uploadEnabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("trailhead.firstrun.branches", "nofirstrun-empty");' >> ${FIREFOX_SETTING} && \
  echo 'pref("browser.aboutwelcome.enabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("security.sandbox.warn_unprivileged_namespaces", false);' >> ${FIREFOX_SETTING} && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# fix line endings and make s6 service executable
RUN sed -i 's/\r$//' /etc/s6-overlay/s6-rc.d/svc-rtsp/run && \
    chmod +x /etc/s6-overlay/s6-rc.d/svc-rtsp/run

# ports and volumes
EXPOSE 3001
EXPOSE 8554

VOLUME /config
