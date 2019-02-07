# docker-berkeleydb

[![Build Status](https://travis-ci.com/lncm/docker-berkeleydb.svg?branch=db-4.8.30.NC)](https://travis-ci.com/lncm/docker-berkeleydb) ![](https://img.shields.io/microbadger/image-size/lncm/berkeleydb/db-4.8.30.NC.svg?style=flat) ![](https://img.shields.io/docker/pulls/lncm/berkeleydb.svg?style=flat)

This is the base image for [lncm/bitcoind] images that rely on Berkeleydb version `db-4.8.30.NC`.

Image is built for two architectures `arm` (on [Travis] using [`qemu`]), and `arm64` (on [Docker Hub]).

[lncm/bitcoind]: https://github.com/lncm/docker-bitcoind/
[Travis]: https://travis-ci.com/lncm/docker-berkeleydb/builds/100074314
[`qemu`]: https://github.com/multiarch/qemu-user-static
[Docker Hub]: https://cloud.docker.com/u/lncm/repository/registry-1.docker.io/lncm/berkeleydb/builds/0060d943-df7f-45a4-9171-363df4e9f616

## Pull

Pulling this image directly is not particularly useful, but can be achieved with:

```bash
docker pull lncm/berkeleydb:db-4.8.30.NC
```

> **NOTE:** correct architecture will be automatically chosen based on the architecture of the CPU the command is run on.

#### Manual

To manually specify the architecture, use one of the commands below.

```bash
docker pull lncm/berkeleydb:db-4.8.30.NC-linux-arm
docker pull lncm/berkeleydb:db-4.8.30.NC-linux-amd64
```

## Dockerfile

To build bitcoind w/o the need to rebuild Berkeleydb, you can do:

```dockerfile
# Pull already build Berkeley DB stage
FROM lncm/berkeleydb:db-4.8.30.NC AS berkeleydb

# Start new stage to build ex. bitocin-core
FROM alpine AS bitcoin-core

# Copy all BDB relevant files to your new stage 
COPY --from=berkeleydb /opt /opt

# …
# continue with your instructions here 
```

