# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN curl -sSL https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u452-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u452b09.tar.gz | tar -xz -C /usr/local

ENV JAVA_HOME=/usr/local/jdk8u452-b09
ENV PATH=$PATH:$JAVA_HOME/bin
