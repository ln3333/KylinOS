# syntax=docker/dockerfile:1

FROM openeuler/openeuler:22.03

# 安装基础依赖（不装 sqlite-devel，改用下方编译的 3.51 提供头文件/库）
RUN yum install -y git curl wget make gcc gcc-c++ zlib-devel libffi-devel openssl-devel \
    iputils \
    net-tools \
    telnet \
    bind-utils \
    bzip2-devel readline-devel xz-devel patch vim unzip jq && \
    yum clean all && \
    rm -rf /var/cache/yum

# ============================================
# 用 SQLite 3.51 替换系统自带的 3.32.3（含运行时 + devel 头文件/库）
# ============================================
# 先移除系统自带的 sqlite / sqlite-devel，再从源码安装 3.51 到 /usr/local
RUN yum remove -y sqlite sqlite-devel 2>/dev/null || true

ARG SQLITE_VERSION=3510300
RUN set -eux; \
    cd /tmp && \
    wget -q "https://www.sqlite.org/2026/sqlite-autoconf-${SQLITE_VERSION}.tar.gz" -O sqlite.tar.gz && \
    tar xzf sqlite.tar.gz && \
    cd sqlite-autoconf-${SQLITE_VERSION} && \
    ./configure --prefix=/usr/local \
        --disable-static \
        --enable-fts5 \
        CPPFLAGS="-DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_DBSTAT_VTAB=1" && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && rm -rf sqlite.tar.gz sqlite-autoconf-${SQLITE_VERSION}

# 使系统使用 3.51：PATH、库路径、以及后续编译（如 Python）能找到头文件与库
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH:-}
ENV CPPFLAGS="-I/usr/local/include ${CPPFLAGS:-}"
ENV LDFLAGS="-L/usr/local/lib ${LDFLAGS:-}"
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-}

# ============================================
# 安装 pyenv 和 Python 3.12.12
# ============================================
ENV PYENV_ROOT=/pyenv
ENV PATH=$PATH:$PYENV_ROOT/bin:$PYENV_ROOT/shims

RUN curl -sSL https://pyenv.run | bash

RUN eval "$(pyenv init -)" && \
    pyenv install 3.12.12 && \
    pyenv global 3.12.12 && \
    pyenv rehash

# ============================================
# 安装 nvm 和 Node.js 20.19.5（所有用户可用）
# ============================================
# 创建 nvm 组
RUN groupadd -r nvm && chmod 755 /opt

# 安装 nvm 到默认位置，再移动到 /opt/nvm
RUN unset NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash && \
    mv /root/.nvm /opt/nvm && \
    chgrp -R nvm /opt/nvm && \
    chmod -R 755 /opt/nvm

# 设置环境变量
ENV NVM_DIR=/opt/nvm
ENV PATH=$NVM_DIR/versions/node/v20.19.5/bin:$PATH

# 设置 Node.js 版本
RUN . "$NVM_DIR/nvm.sh" && \
    nvm install 20.19.5 && \
    nvm alias default 20.19.5 && \
    nvm use 20.19.5

# 创建系统级 profile 脚本，使所有用户都能使用 nvm
RUN echo 'export NVM_DIR="/opt/nvm"' > /etc/profile.d/nvm.sh && \
    echo 'export PATH=$NVM_DIR/versions/node/v20.19.5/bin:$PATH' >> /etc/profile.d/nvm.sh && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /etc/profile.d/nvm.sh && \
    chmod 644 /etc/profile.d/nvm.sh

# ============================================
# 安装 Google Chrome
# ============================================
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm && \
    yum install -y google-chrome-stable_current_x86_64.rpm && \
    rm -f google-chrome-stable_current_x86_64.rpm
