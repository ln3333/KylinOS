# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# ============================================
# 安装基础依赖
# ============================================
RUN yum install -y git curl make gcc gcc-c++ zlib-devel libffi-devel openssl-devel \
    bzip2-devel readline-devel sqlite-devel xz-devel patch vim unzip jq docker && \
    yum clean all && \
    rm -rf /var/cache/yum

# ============================================
# 安装 OpenJDK 8
# ============================================
RUN curl -sSL https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u452-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u452b09.tar.gz | tar -xz -C /usr/local && \
    mv /usr/local/jdk8u452-b09 /usr/local/openjdk8

ENV JAVA_HOME_8=/usr/local/openjdk8
ENV PATH=$PATH:$JAVA_HOME_8/bin

# ============================================
# 安装 OpenJDK 11
# ============================================
RUN curl -sSL https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.23%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.23_9.tar.gz | tar -xz -C /usr/local && \
    mv /usr/local/jdk-11.0.23+9 /usr/local/openjdk11

ENV JAVA_HOME_11=/usr/local/openjdk11
ENV PATH=$PATH:$JAVA_HOME_11/bin

# ============================================
# 安装 Dragonwell Extended 8
# ============================================
ARG DRAGONWELL_EXTENDED_8_URL="https://dragonwell.oss-cn-shanghai.aliyuncs.com/8.29.28/Alibaba_Dragonwell_Extended_8.29.28_x64_linux.tar.gz"

RUN set -eux; \
    tmp="/tmp/dragonwell-extended8.tar.gz"; \
    curl -fsSL "${DRAGONWELL_EXTENDED_8_URL}" -o "${tmp}"; \
    topdir="$(tar -tzf "${tmp}" | head -n 1 | cut -d/ -f1)"; \
    tar -xzf "${tmp}" -C /usr/local; \
    rm -f "${tmp}"; \
    mv "/usr/local/${topdir}" /usr/local/dragonwell-extended8

ENV JAVA_HOME_DRAGONWELL_8=/usr/local/dragonwell-extended8
ENV PATH=$PATH:$JAVA_HOME_DRAGONWELL_8/bin

# ============================================
# 安装 Dragonwell Extended 11
# ============================================
ARG DRAGONWELL_EXTENDED_11_URL="https://dragonwell.oss-cn-shanghai.aliyuncs.com/11.0.31.28.11/Alibaba_Dragonwell_Extended_11.0.31.28.11_x64_linux.tar.gz"

RUN set -eux; \
    tmp="/tmp/dragonwell-extended11.tar.gz"; \
    curl -fsSL "${DRAGONWELL_EXTENDED_11_URL}" -o "${tmp}"; \
    topdir="$(tar -tzf "${tmp}" | head -n 1 | cut -d/ -f1)"; \
    tar -xzf "${tmp}" -C /usr/local; \
    rm -f "${tmp}"; \
    mv "/usr/local/${topdir}" /usr/local/dragonwell-extended11

ENV JAVA_HOME_DRAGONWELL_11=/usr/local/dragonwell-extended11
ENV PATH=$PATH:$JAVA_HOME_DRAGONWELL_11/bin

# ============================================
# 安装 Dragonwell Extended 21
# ============================================
ARG DRAGONWELL_EXTENDED_21_URL="https://dragonwell.oss-cn-shanghai.aliyuncs.com/21.0.9.0.9%2B10/Alibaba_Dragonwell_Extended_21.0.9.0.9.10_x64_linux.tar.gz"

RUN set -eux; \
    tmp="/tmp/dragonwell-extended21.tar.gz"; \
    curl -fsSL "${DRAGONWELL_EXTENDED_21_URL}" -o "${tmp}"; \
    topdir="$(tar -tzf "${tmp}" | head -n 1 | cut -d/ -f1)"; \
    tar -xzf "${tmp}" -C /usr/local; \
    rm -f "${tmp}"; \
    mv "/usr/local/${topdir}" /usr/local/dragonwell-extended21

ENV JAVA_HOME_DRAGONWELL_21=/usr/local/dragonwell-extended21
ENV PATH=$PATH:$JAVA_HOME_DRAGONWELL_21/bin

# 设置默认JAVA_HOME为OpenJDK 8
ENV JAVA_HOME=/usr/local/openjdk8

# ============================================
# 安装 Maven
# ============================================
RUN curl -sSL https://dlcdn.apache.org/maven/maven-3/3.9.16/binaries/apache-maven-3.9.16-bin.tar.gz | tar -xz -C /usr/local && \
    mv /usr/local/apache-maven-3.9.16 /usr/local/maven

ENV MAVEN_HOME=/usr/local/maven
ENV PATH=$PATH:$MAVEN_HOME/bin

# ============================================
# 安装 SonarScanner CLI（多版本共存）
# - 默认 sonar-scanner -> 8.0.1
# ============================================
ARG SONAR_SCANNER_CLI_8_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-8.0.1.6346-linux-x64.zip"
ARG SONAR_SCANNER_CLI_4_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.1.3023-linux.zip"

RUN set -eux; \
    mkdir -p /opt; \
    curl -fsSL "$SONAR_SCANNER_CLI_8_URL" -o /tmp/sonar-scanner-cli-8.0.1.zip; \
    unzip -q /tmp/sonar-scanner-cli-8.0.1.zip -d /opt; \
    mv /opt/sonar-scanner-8.0.1.6346-linux-x64 /opt/sonar-scanner-cli-8.0.1; \
    rm -f /tmp/sonar-scanner-cli-8.0.1.zip; \
    \
    curl -fsSL "$SONAR_SCANNER_CLI_4_URL" -o /tmp/sonar-scanner-cli-4.8.1.zip; \
    unzip -q /tmp/sonar-scanner-cli-4.8.1.zip -d /opt; \
    mv /opt/sonar-scanner-4.8.1.3023-linux /opt/sonar-scanner-cli-4.8.1; \
    rm -f /tmp/sonar-scanner-cli-4.8.1.zip; \
    \
    ln -sf /opt/sonar-scanner-cli-8.0.1/bin/sonar-scanner /usr/local/bin/sonar-scanner-8.0.1; \
    ln -sf /opt/sonar-scanner-cli-4.8.1/bin/sonar-scanner /usr/local/bin/sonar-scanner-4.8.1; \
    ln -sf /opt/sonar-scanner-cli-8.0.1/bin/sonar-scanner /usr/local/bin/sonar-scanner

# ============================================
# 安装 pyenv 和 Python 多个版本
# ============================================
ENV PYENV_ROOT=/pyenv
ENV PATH=$PATH:$PYENV_ROOT/bin:$PYENV_ROOT/shims

RUN curl -sSL https://pyenv.run | bash

# 安装多个Python版本
RUN eval "$(pyenv init -)" && \
    pyenv install 3.8.20 && \
    pyenv install 3.9.25 && \
    pyenv install 3.10.19 && \
    pyenv install 3.11.14 && \
    pyenv install 3.12.12 && \
    pyenv install 3.13.9 && \
    pyenv install 3.14.0

# 初始化pyenv并设置权限
RUN eval "$(pyenv init -)" && pyenv rehash || true && \
    chmod -R a+rx /pyenv && \
    mkdir -p /pyenv/shims && chmod -R a+w /pyenv/shims

# 设置默认Python版本
ENV PYENV_VERSION=3.12.12

# ============================================
# 安装 nvm 和 Node.js 多个版本
# ============================================
ENV NVM_DIR=/root/.nvm

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 配置nvm到bashrc
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# 安装多个Node.js版本
RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    for version in 14.21.3 15.14.0 16.20.2 17.9.1 18.20.8 19.9.0 20.19.5 21.7.3 22.21.1 23.11.1 24.11.1; do \
        echo "Installing Node.js $version..." && \
        nvm install $version && \
        nvm use $version && \
        npm install -g yarn; \
    done && \
    nvm alias default 20.19.5

# 设置默认Node.js版本到PATH
ENV PATH=/root/.nvm/versions/node/v20.19.5/bin:$PATH

# ============================================
# 创建切换脚本（简化版本，用户可以在容器内手动切换JAVA_HOME）
# ============================================
RUN echo '#!/bin/bash' > /usr/local/bin/switch-java && \
    echo 'case "$1" in' >> /usr/local/bin/switch-java && \
    echo '  openjdk8) export JAVA_HOME=/usr/local/openjdk8 ;;' >> /usr/local/bin/switch-java && \
    echo '  openjdk11) export JAVA_HOME=/usr/local/openjdk11 ;;' >> /usr/local/bin/switch-java && \
    echo '  dragonwell8) export JAVA_HOME=/usr/local/dragonwell-extended8 ;;' >> /usr/local/bin/switch-java && \
    echo '  dragonwell11) export JAVA_HOME=/usr/local/dragonwell-extended11 ;;' >> /usr/local/bin/switch-java && \
    echo '  dragonwell21) export JAVA_HOME=/usr/local/dragonwell-extended21 ;;' >> /usr/local/bin/switch-java && \
    echo '  *) echo "Usage: switch-java {openjdk8|openjdk11|dragonwell8|dragonwell11|dragonwell21}"; exit 1 ;;' >> /usr/local/bin/switch-java && \
    echo 'esac' >> /usr/local/bin/switch-java && \
    echo 'export PATH=$(echo $PATH | sed -E "s|/usr/local/(openjdk|dragonwell-extended)[^:]*/bin:||g"):$JAVA_HOME/bin' >> /usr/local/bin/switch-java && \
    echo 'java -version' >> /usr/local/bin/switch-java && \
    chmod +x /usr/local/bin/switch-java

# ============================================
# 验证安装
# ============================================
RUN echo "=== Java Versions ===" && \
    /usr/local/openjdk8/bin/java -version && \
    echo "" && \
    /usr/local/openjdk11/bin/java -version && \
    echo "" && \
    /usr/local/dragonwell-extended8/bin/java -version && \
    echo "" && \
    /usr/local/dragonwell-extended11/bin/java -version && \
    echo "" && \
    /usr/local/dragonwell-extended21/bin/java -version && \
    echo "" && \
    echo "=== Maven Version ===" && \
    /usr/local/maven/bin/mvn -version && \
    echo "" && \
    echo "=== SonarScanner CLI Versions ===" && \
    sonar-scanner --version && \
    echo "" && \
    sonar-scanner-8.0.1 --version && \
    echo "" && \
    sonar-scanner-4.8.1 --version && \
    echo "" && \
    echo "=== Python Versions (pyenv) ===" && \
    eval "$(pyenv init -)" && pyenv versions && \
    echo "" && \
    echo "=== Node.js Versions (nvm) ===" && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm list

