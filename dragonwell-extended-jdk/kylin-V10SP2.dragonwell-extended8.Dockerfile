# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG DRAGONWELL_EXTENDED_8_URL="https://dragonwell.oss-cn-shanghai.aliyuncs.com/8.27.26-test-dragonwell_extended/Alibaba_Dragonwell_Extended_8.27.26_x64_linux.tar.gz"

RUN set -eux; \
    tmp="/tmp/dragonwell-extended8.tar.gz"; \
    curl -fsSL "${DRAGONWELL_EXTENDED_8_URL}" -o "${tmp}"; \
    topdir="$(tar -tzf "${tmp}" | head -n 1 | cut -d/ -f1)"; \
    tar -xzf "${tmp}" -C /usr/local; \
    rm -f "${tmp}"; \
    mv "/usr/local/${topdir}" /usr/local/dragonwell-extended8

ENV JAVA_HOME=/usr/local/dragonwell-extended8
ENV PATH=$PATH:$JAVA_HOME/bin

