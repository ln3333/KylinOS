# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG DRAGONWELL_EXTENDED_21_URL="https://dragonwell.oss-cn-shanghai.aliyuncs.com/21.0.9.0.9%2B10/Alibaba_Dragonwell_Extended_21.0.9.0.9.10_x64_linux.tar.gz"

RUN set -eux; \
    tmp="/tmp/dragonwell-extended21.tar.gz"; \
    curl -fsSL "${DRAGONWELL_EXTENDED_21_URL}" -o "${tmp}"; \
    topdir="$(tar -tzf "${tmp}" | head -n 1 | cut -d/ -f1)"; \
    tar -xzf "${tmp}" -C /usr/local; \
    rm -f "${tmp}"; \
    mv "/usr/local/${topdir}" /usr/local/dragonwell-extended21

ENV JAVA_HOME=/usr/local/dragonwell-extended21
ENV PATH=$PATH:$JAVA_HOME/bin

