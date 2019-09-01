# Build stage for BerkeleyDB
FROM alpine:3.10 as berkeleydb

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories && \
    apk add --no-cache --update \
        autoconf \
        automake \
        build-base \
        libressl

ENV BDB_VERSION=db-4.8.30.NC
ENV BDB_PREFIX=/opt/${BDB_VERSION}

# Download, verify checksum, and uncompress BerkeleyDB source code
RUN wget https://download.oracle.com/berkeley-db/${BDB_VERSION}.tar.gz && \
    echo "12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  ${BDB_VERSION}.tar.gz" | sha256sum -c && \
    tar -xzf "${BDB_VERSION}.tar.gz"

RUN sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BDB_VERSION}/dbinc/atomic.h
RUN mkdir -p ${BDB_PREFIX}

WORKDIR /${BDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BDB_PREFIX}
RUN make -j4
RUN make install
RUN rm -rf ${BDB_PREFIX}/docs


FROM alpine:3.10

LABEL maintainer="Damian Mee (@meeDamian)"

COPY --from=berkeleydb /opt /
