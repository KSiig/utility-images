FROM ubuntu:20.04

ARG COLUMN_VERSION=2.36

RUN apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  curl jq build-essential ca-certificates lsb-release gnupg wget unzip zip \
  apt-transport-https sudo software-properties-common git gnupg2 fzf

# Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
  sh get-docker.sh

# Install Column
RUN wget https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${COLUMN_VERSION}/util-linux-${COLUMN_VERSION}.tar.gz && \
  tar -xvf util-linux-${COLUMN_VERSION}.tar.gz && \
  cd util-linux-${COLUMN_VERSION} && \
  ./configure && make column && \
  mv column /usr/local/bin && \
  mv .libs/column /usr/local/bin

RUN rm -rf /var/lib/apt/lists/*

# Cleanup
RUN apt-get clean; apt-get autoclean
