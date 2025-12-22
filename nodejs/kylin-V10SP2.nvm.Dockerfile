# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=20.19.5

RUN yum install -y git curl make gcc gcc-c++ && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    for version in 14.21.3 15.14.0 16.20.2 17.9.1 18.20.8 19.9.0 20.19.5 21.7.3 22.21.1 23.11.1 24.11.1; do \
        echo "Installing Node.js $version..." && \
        nvm install $version && \
        nvm use $version && \
        npm install -g yarn; \
    done && \
    nvm alias default 20.19.5

ENV PATH=/root/.nvm/versions/node/v20.19.5/bin:$PATH



