FROM ubuntu:trusty

MAINTAINER Roeland Jago Douma <roeland@famdouma.nl>

RUN apt-get update && \
    apt-get install -y wget libsqlite3-dev libssl-dev cmake git \
        software-properties-common build-essential mesa-common-dev fuse rsync

RUN add-apt-repository -y ppa:beineri/opt-qt58-trusty && \
    apt-get update && \
    apt-get install -y qt58base qt58tools

