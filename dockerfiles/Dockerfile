FROM ubuntu:20.04

RUN apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  curl jq build-essential ca-certificates lsb-release gnupg wget unzip zip \
  apt-transport-https sudo software-properties-common git gnupg2 fzf

# Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
  sh get-docker.sh

RUN rm -rf /var/lib/apt/lists/*

# Cleanup
RUN apt-get clean; apt-get autoclean
