# Build stage for BerkeleyDB
FROM alpine:3.10 as berkeleydb

# Make sure packages are downloaded using HTTPS
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories && \
    apk add --no-cache --update \
        autoconf \
        automake \
        build-base \
        libressl
#
# Use install script from official Bitcoin repo, as it applies some necessary patches. Example:
#   https://github.com/bitcoin/bitcoin/blob/1ac454a3844b9b8389de0f660fa9455c0efa7140/contrib/install_db4.sh#L73-L85
#   This enables build on aarch64, as otherwise it's an unknown architecture.
#
ENV BITCOIN_COMMIT=1ac454a3844b9b8389de0f660fa9455c0efa7140

# Script file to be downloaded from Bitcoin repository, and it's known hash
ENV SCRIPT_FILE=install_db4.sh
ENV SCRIPT_HASH=ffd03d20fb36eaeec7d52d05a13cc18a91e9c42557f82ed5afc4dd74a0754c4d

# Download the script, and verify checksum matches
RUN wget -q "https://raw.githubusercontent.com/bitcoin/bitcoin/${BITCOIN_COMMIT}/contrib/${SCRIPT_FILE}" && \
    echo "${SCRIPT_HASH}  ${SCRIPT_FILE}" | sha256sum -c && \
    chmod +x "./${SCRIPT_FILE}"


# While the original script fixes some things, it also needs a bit patching for Alpine 😅
#   The patch here removes the clang patch that's not used on Alpine, and
#   applies a necessary patch for `dbinc/atomic.h`.
ENV PATCH_FILE=bdb-install-script.patch
ENV PATCH_HASH=559d892c1d253e66e93cbc0e459a86b88b1a30bdd5414172248dfc5c1a3b7ec2

COPY /${PATCH_FILE} .

# Only apply the patch if checksum matches
RUN echo "${PATCH_HASH}  ${PATCH_FILE}" | sha256sum -c && \
    patch -p0 -i ${PATCH_FILE}

# Run BerkeleyDB installation
RUN /${SCRIPT_FILE} /opt/

# Remove unnecessary fluff
RUN rm -rf /opt/db4/db-4.8.30.NC /opt/db4/docs


# Create a separate final stage that can be as small as possible
FROM alpine:3.10

LABEL maintainer="Damian Mee (@meeDamian)"

COPY --from=berkeleydb /opt /opt
