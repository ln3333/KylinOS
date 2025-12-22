# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN yum install -y libaio unzip wget

RUN echo "Downloading Oracle Instant Client 21.20.0.0.0..." && \
    cd /tmp && \
    ORACLE_CLIENT_ZIP="instantclient-basic-linux.x64-21.20.0.0.0dbru.zip" && \
    ORACLE_DOWNLOAD_URL="https://download.oracle.com/otn_software/linux/instantclient/2120000/${ORACLE_CLIENT_ZIP}" && \
    wget --no-check-certificate \
         --header="Cookie: oraclelicense=accept-securebackup-cookie" \
         --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
         -O ${ORACLE_CLIENT_ZIP} \
         ${ORACLE_DOWNLOAD_URL} && \
    if [ ! -f ${ORACLE_CLIENT_ZIP} ] || [ ! -s ${ORACLE_CLIENT_ZIP} ]; then \
        echo "ERROR: Oracle Instant Client ZIP file is missing or empty" && exit 1; \
    fi && \
    echo "Extracting Oracle Instant Client..." && \
    unzip -q ${ORACLE_CLIENT_ZIP} -d /usr/local && \
    rm -f ${ORACLE_CLIENT_ZIP} && \
    cd /usr/local && \
    ORACLE_DIR=$(ls -d instantclient_* 2>/dev/null | head -1) && \
    if [ -z "$ORACLE_DIR" ]; then \
        ORACLE_DIR=$(ls -d oracle-instantclient-* 2>/dev/null | head -1); \
    fi && \
    if [ -n "$ORACLE_DIR" ] && [ -d "$ORACLE_DIR" ]; then \
        mv $ORACLE_DIR oracle-instantclient && \
        echo "Oracle Instant Client installed successfully in /usr/local/oracle-instantclient"; \
    else \
        echo "Error: Oracle Instant Client directory not found after extraction" && \
        echo "Available files in /usr/local:" && \
        ls -la /usr/local && \
        exit 1; \
    fi && \
    cd /usr/local/oracle-instantclient && \
    if ls libclntsh.so.* 1> /dev/null 2>&1; then \
        LIB_VERSION=$(ls libclntsh.so.* | head -1 | sed 's/libclntsh\.so\.//') && \
        ln -sf libclntsh.so.${LIB_VERSION} libclntsh.so || true; \
    fi

ENV ORACLE_HOME=/usr/local/oracle-instantclient
ENV LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH
ENV PATH=$PATH:$ORACLE_HOME

RUN if [ -d "$ORACLE_HOME" ] && [ -f "$ORACLE_HOME/libclntsh.so" ]; then \
        echo "Oracle Instant Client verification:" && \
        ls -lh $ORACLE_HOME/libclntsh.so* && \
        echo "ORACLE_HOME: $ORACLE_HOME" && \
        echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"; \
    else \
        echo "Warning: Oracle Instant Client may not be properly installed"; \
        exit 1; \
    fi

