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

# Install Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" && \
  apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y azure-cli > /dev/null && \
  az extension add --name azure-devops

RUN rm -rf /var/lib/apt/lists/*

# Cleanup
RUN apt-get clean; apt-get autoclean
