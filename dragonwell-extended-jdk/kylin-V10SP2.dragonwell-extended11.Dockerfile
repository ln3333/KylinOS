# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG DRAGONWELL_EXTENDED_11_URL="https://dragonwell.oss-cn-shanghai.aliyuncs.com/11.0.31.28.11/Alibaba_Dragonwell_Extended_11.0.31.28.11_x64_linux.tar.gz"

RUN set -eux; \
    tmp="/tmp/dragonwell-extended11.tar.gz"; \
    curl -fsSL "${DRAGONWELL_EXTENDED_11_URL}" -o "${tmp}"; \
    topdir="$(tar -tzf "${tmp}" | head -n 1 | cut -d/ -f1)"; \
    tar -xzf "${tmp}" -C /usr/local; \
    rm -f "${tmp}"; \
    mv "/usr/local/${topdir}" /usr/local/dragonwell-extended11

ENV JAVA_HOME=/usr/local/dragonwell-extended11
ENV PATH=$PATH:$JAVA_HOME/bin
