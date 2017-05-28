FROM ubuntu:trusty

MAINTAINER Roeland Jago Douma <roeland@famdouma.nl>

RUN apt-get update

RUN apt-get install -y wget libsqlite3-dev libssl-dev cmake git software-properties-common build-essential mesa-common-dev fuse

RUN add-apt-repository -y ppa:beineri/opt-qt562-trusty

RUN apt-get update

RUN apt-get install -y qt56base qt56tools
