# This Dockerfile builds Berkeleydb at version db-4.8.30.NC so it can be reused by all Bitcoin Core builds

# Target CPU archtecture of built berkeleydb library
ARG ARCH

# Define default version so that it doesn't have to be repreated throughout the file
ARG VER_ALPINE=3.11



#
## This stage builds BerkeleyDB
#
# NOTE: `${ARCH:+${ARCH}/}` - if ARCH is set, append `/` to it, leave it empty otherwise
FROM ${ARCH:+${ARCH}/}alpine:${VER_ALPINE} AS berkeleydb

# Use APK repos over HTTPS. See: https://github.com/gliderlabs/docker-alpine/issues/184
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories

RUN apk add --no-cache  autoconf  automake  build-base  libressl

# Use install script from official Bitcoin repo, as Bitcoin-required version of BDB is becoming ancient, and causes
# problems.  For example, due to _ancient_ `config.guess` and `config.sub`, the `aarch64` architecture is not
# recognized, and compilation on it is impossible.  See:
#   https://github.com/bitcoin/bitcoin/blob/28fbe68fdcac2a06f359b1e48555a3d23015c2b7/contrib/install_db4.sh#L76-L88

# Bitcoin repository commit to be used to pull BDB install script from
ENV BITCOIN_COMMIT=28fbe68fdcac2a06f359b1e48555a3d23015c2b7

# Script file to be downloaded from Bitcoin repository, and it's hash at the time
ENV SCRIPT_FILE=install_db4.sh
ENV SCRIPT_HASH=2dd5b31bd47be6f029bd9c11b00deb8c975aa34c3007b4e9dade781a9a76cbb8

# Download the script, and verify that the checksum matches
ADD https://raw.githubusercontent.com/bitcoin/bitcoin/${BITCOIN_COMMIT}/contrib/${SCRIPT_FILE}  ./

RUN echo "${SCRIPT_HASH}  ${SCRIPT_FILE}" | sha256sum -c - && \
    chmod +x "./${SCRIPT_FILE}"

# While the original script fixes some things, it is intended for a different toolchain.  One of the patches fixes
# some clang incompatibility issue, while breaking it for the _clang-less_ Alpine. The patch applied below prevents that
# and also applies necessary changes to `dbinc/atomic.h`.
ENV PATCH_FILE=bdb-install-script.patch
ENV PATCH_HASH=559d892c1d253e66e93cbc0e459a86b88b1a30bdd5414172248dfc5c1a3b7ec2

COPY ${PATCH_FILE} .

# Verify checksum, and if it matches, apply the patch
RUN echo "${PATCH_HASH}  ${PATCH_FILE}" | sha256sum -c - && \
    patch -p0 -i ${PATCH_FILE}

# Download, and compile BerkeleyDB v4.8.30.NC
RUN /${SCRIPT_FILE} /opt/

# These things are unnecessary, and don't have to be moved to the next stage
RUN rm -rf /opt/db4/db-4.8.30.NC  /opt/db4/docs



#
## Create a minimal final stage
#
FROM scratch AS final

LABEL maintainer="Damian Mee (@meeDamian)"

COPY --from=berkeleydb /opt /opt
