# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ENV NGINX_VERSION=1.29.3
ENV NJS_VERSION=0.9.4

# Install build dependencies and runtime dependencies
RUN yum install -y \
    gcc \
    gcc-c++ \
    make \
    pcre-devel \
    zlib-devel \
    openssl-devel \
    libxslt-devel \
    gd-devel \
    geoip-devel \
    curl \
    ca-certificates \
    gettext \
    && yum clean all \
    && rm -rf /var/cache/yum

# Create nginx user/group
RUN groupadd --system --gid 101 nginx \
    && useradd --system --gid nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx

# Download and build nginx from source
RUN set -x \
    && cd /tmp \
    && curl -f -L -O https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && curl -f -L -O https://github.com/nginx/njs/archive/${NJS_VERSION}.tar.gz \
    && tar xzf nginx-${NGINX_VERSION}.tar.gz \
    && tar xzf ${NJS_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
        --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-http_slice_module \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_v3_module \
        --add-module=../njs-${NJS_VERSION}/nginx \
    && make -j$(getconf _NPROCESSORS_ONLN || echo 1) \
    && make install \
    && cd / \
    && rm -rf /tmp/nginx-${NGINX_VERSION}* /tmp/njs-${NJS_VERSION}* \
    && mkdir -p /var/cache/nginx/client_temp \
    && mkdir -p /var/cache/nginx/proxy_temp \
    && mkdir -p /var/cache/nginx/fastcgi_temp \
    && mkdir -p /var/cache/nginx/uwsgi_temp \
    && mkdir -p /var/cache/nginx/scgi_temp \
    && mkdir -p /var/log/nginx \
    && mkdir -p /etc/nginx/conf.d \
    && mkdir -p /etc/nginx/templates \
    && mkdir -p /docker-entrypoint.d

# Remove build dependencies to reduce image size
# Note: Runtime libraries (libxslt, gd, geoip) are needed for dynamic modules
RUN yum remove -y \
    gcc \
    gcc-c++ \
    make \
    libxslt-devel \
    gd-devel \
    geoip-devel \
    && yum install -y \
    libxslt \
    gd \
    GeoIP \
    && yum clean all \
    && rm -rf /var/cache/yum

# Forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#     && ln -sf /dev/stderr /var/log/nginx/error.log

# Copy entrypoint scripts
COPY docker-entrypoint.sh /
COPY 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY 15-local-resolvers.envsh /docker-entrypoint.d
COPY 20-envsubst-on-templates.sh /docker-entrypoint.d
COPY 30-tune-worker-processes.sh /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]

