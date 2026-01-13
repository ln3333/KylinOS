# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN curl -sSL https://dlcdn.apache.org/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz | tar -xz -C /usr/local

ENV PATH=$PATH:/usr/local/apache-maven-3.9.12/bin/

