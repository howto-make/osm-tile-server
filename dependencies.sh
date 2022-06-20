#!/bin/bash

apt-get update \
  && apt-get install sudo wget gnupg2 lsb-core -y \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo "deb [ trusted=yes ] http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
  && sudo apt-get update -q \
  && sudo apt-get install -y apt-transport-https ca-certificates \
  && sudo apt-get install -qy --no-install-recommends --allow-unauthenticated \
  software-properties-common \
  libboost-dev \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-python-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  subversion \
  git-core \
  tar \
  unzip \
  wget \
  bzip2 \
  build-essential \
  autoconf \
  libtool \
  libxml2-dev \
  libgeos-dev \
  libpq-dev \
  libbz2-dev \
  munin-node \
  munin \
  libprotobuf-c-dev \
  protobuf-c-compiler \
  protobuf-compiler \
  python-protobuf \
  libc6-dev \
  libgcc1 \
  protobuf-c-compiler \
  libfreetype6-dev \
  libtiff5-dev \
  libicu-dev \
  libgdal-dev \
  libcairo-dev \
  libcairomm-1.0-dev \
  apache2 \
  apache2-dev \
  libagg-dev \
  ttf-unifont \
  autoconf \
  apache2 \
  apache2-dev \
  libtool \
  libxml2-dev \
  libbz2-dev \
  libgeos-dev \
  libgeos++-dev \
  libproj-dev \
  gdal-bin \
  apt-utils \
  mapnik-utils \
  libmapnik-dev \
  clang \
  fonts-noto-cjk \
  fonts-noto-hinted \
  fonts-noto-unhinted \
  gcc \
  make \
  libfreetype6-dev \
  libicu-dev \
  liblua5.3-dev \
  lua5.3 \
  libmapnik-dev \
  autotools-dev \
  automake \
  npm \
  nodejs  \
  mapnik-utils \
  osmium-tool \
  osmosis \
  postgis \
  postgresql-12 \
  postgresql-server-dev-12 \
  postgresql-contrib-12 \
  protobuf-c-compiler \
  python-is-python3 \
  python3-mapnik \
  python3-lxml \
  python3-psycopg2 \
  python3-shapely \
  python3-pip \
  curl \
  dpkg \
  sudo \
  python-pycurl \
  python-apt \
  && sudo apt --fix-missing install  \
  && sudo apt-get clean autoclean \
  && sudo apt-get autoremove --yes \
  && ldconfig 
