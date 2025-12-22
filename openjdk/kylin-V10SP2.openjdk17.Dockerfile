# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN curl -sSL https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jdk_x64_linux_hotspot_17.0.9_9.tar.gz | tar -xz -C /usr/local

ENV JAVA_HOME=/usr/local/jdk-17.0.9+9
ENV PATH=$PATH:$JAVA_HOME/bin
