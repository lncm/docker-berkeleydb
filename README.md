# docker-berkeleydb

This is the base image for [lncm/bitcoind] images that rely on Berkeleydb version `db-4.8.30.NC`.

Image is built for two architectures `arm` (on [Travis] using [`qemu`]), and `arm64` (on [Docker Hub]).

[lncm/bitcoind]: https://github.com/lncm/docker-bitcoind/
[Travis]: https://travis-ci.com/lncm/docker-berkeleydb/builds/99959318
[`qemu`]: https://github.com/multiarch/qemu-user-static
[Docker Hub]: https://cloud.docker.com/u/lncm/repository/registry-1.docker.io/lncm/berkeleydb/builds/5f079ed3-0961-4f32-ba75-e0a3e6ea107c

## Pull

Pulling this image directly is not particularly useful, but can be achieved with:

```bash
docker pull lncm/berkeleydb:db-4.8.30.NC
```

> **NOTE:** correct architecture will be automatically chosen based on the architecture of the CPU the command is run on.

#### Manual

To manually specify the architecture, use one of the commands below.

```bash
docker pull lncm/berkeleydb:linux-arm-db-4.8.30.NC
docker pull lncm/berkeleydb:linux-amd64-db-4.8.30.NC
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
```

