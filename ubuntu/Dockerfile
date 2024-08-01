FROM ubuntu:22.04

WORKDIR /root

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update
RUN apt-get -y install \
    tzdata \
    ca-certificates \
    gcc \
    make \
    liblz4-tool \
    lz4 \
    curl \
    gnupg \
    expect \
    screen \
    vim \
    jq \
    wget \
    unzip \
    git \
    zip
ENV TZ="UTC"
RUN echo "${TZ}" > /etc/timezone \
          && dpkg-reconfigure --frontend noninteractive tzdata

#   docker build --no-cache -t sateanode/ubuntu:latest .       