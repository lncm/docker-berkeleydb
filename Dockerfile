# Note: All `ARG` specified **before** the first `FROM`, are considered global, and can be used in `FROM` directives.
ARG ALPINE_VERSION=3.10

# Build stage for BerkeleyDB
FROM alpine:${ALPINE_VERSION} as berkeleydb

# Make sure packages are downloaded using HTTPS
RUN sed -i 's|http://dl-cdn.alpinelinux.org|https://alpine.global.ssl.fastly.net|g' /etc/apk/repositories && \
    apk add --no-cache --update \
        autoconf \
        automake \
        build-base \
        libressl

# Use install script from official Bitcoin repo, as Bitcoin-required version of BDB is becoming ancient, and causes
# problems.  For example, due to _ancient_ `config.guess` and `config.sub`, the `aarch64` architecture is not
# recognized, and compilation on it is impossible.  See:
#   https://github.com/bitcoin/bitcoin/blob/1ac454a3844b9b8389de0f660fa9455c0efa7140/contrib/install_db4.sh#L73-L85

# Bitcoin repository commit to be used to pull BDB install script from
ENV BITCOIN_COMMIT=1ac454a3844b9b8389de0f660fa9455c0efa7140

# Script file to be downloaded from Bitcoin repository, and it's hash at the time
ENV SCRIPT_FILE=install_db4.sh
ENV SCRIPT_HASH=ffd03d20fb36eaeec7d52d05a13cc18a91e9c42557f82ed5afc4dd74a0754c4d

# Download the script, and verify that the checksum matches
RUN wget -q "https://raw.githubusercontent.com/bitcoin/bitcoin/${BITCOIN_COMMIT}/contrib/${SCRIPT_FILE}" && \
    echo "${SCRIPT_HASH}  ${SCRIPT_FILE}" | sha256sum -c && \
    chmod +x "./${SCRIPT_FILE}"


# While the original script fixes some things, it is intended for a different toolchain.  One of the patches fixes
# some clang incompatibility issue, while breaking it for the _clang-less_ Alpine. The patch applied below prevents that
# and also applies necessary changes to `dbinc/atomic.h`.
ENV PATCH_FILE=bdb-install-script.patch
ENV PATCH_HASH=559d892c1d253e66e93cbc0e459a86b88b1a30bdd5414172248dfc5c1a3b7ec2

COPY /${PATCH_FILE} .

# Verify checksum, and if it matches, apply the patch
RUN echo "${PATCH_HASH}  ${PATCH_FILE}" | sha256sum -c && \
    patch -p0 -i ${PATCH_FILE}

# Download, and compile BerkeleyDB v4.8.30.NC
RUN /${SCRIPT_FILE} /opt/

# These things are unnecessary, and don't have to be moved to the next stage
RUN rm -rf /opt/db4/db-4.8.30.NC /opt/db4/docs


# Create a separate final stage that can be as small as possible
FROM alpine:${ALPINE_VERSION}

LABEL maintainer="Damian Mee (@meeDamian)"

COPY --from=berkeleydb /opt /opt
