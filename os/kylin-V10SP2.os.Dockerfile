# syntax=docker/dockerfile:1

FROM centos:centos8 AS bootstrap

RUN rm -rf /target && mkdir -p /target/etc/yum.repos.d && mkdir -p /etc/pki/rpm-gpg
COPY kylin-V10SP2.repo /target/etc/yum.repos.d/kylin.repo
COPY RPM-GPG-KEY-kylin /target/etc/pki/rpm-gpg/RPM-GPG-KEY-kylin
COPY RPM-GPG-KEY-kylin /etc/pki/rpm-gpg/RPM-GPG-KEY-kylin

RUN yum --installroot=/target \
    --releasever=10 \
    --setopt=tsflags=nodocs \
    install -y kylin-release coreutils rpm yum bash procps tar ca-certificates curl nc

FROM scratch AS runner
COPY --from=bootstrap /target /
RUN yum --releasever=10 \
    --setopt=tsflags=nodocs \
    install -y kylin-release coreutils rpm yum bash procps tar ca-certificates curl nc
RUN yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/log/*
RUN cp /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && \
    build-locale-archive --install-langs="en:zh"

FROM scratch
COPY --from=runner / /
ENV LANG=C.UTF-8

CMD /bin/bash
