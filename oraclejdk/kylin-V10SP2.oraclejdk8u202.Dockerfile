# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

COPY jdk-8u202-linux-x64.tar.gz /tmp/jdk-8u202-linux-x64.tar.gz

RUN tar -xzf /tmp/jdk-8u202-linux-x64.tar.gz -C /usr/local && \
    rm -f /tmp/jdk-8u202-linux-x64.tar.gz && \
    mv /usr/local/jdk1.8.0_202 /usr/local/jdk8u202

ENV JAVA_HOME=/usr/local/jdk8u202
ENV PATH=$PATH:$JAVA_HOME/bin

