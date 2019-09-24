# lncm/berkeleydb

[![Build Status](https://github.com/lncm/docker-berkeleydb/workflows/Build%20BerkeleyDB/badge.svg)](https://github.com/lncm/docker-berkeleydb/actions) ![](https://img.shields.io/microbadger/image-size/lncm/berkeleydb/db-4.8.30.NC.svg?style=flat) ![](https://img.shields.io/docker/pulls/lncm/berkeleydb.svg?style=flat)


This is the base image for [lncm/bitcoind] Docker images that rely on Berkeleydb version `db-4.8.30.NC`.  This stage is separated from the main bitcoind build process for two reasons:

1. BDB never changes and is only useful when bitcoind is compiled with wallet support enabled,
1. `qemu`-emulated builds take a very long time, separating out this part of the build helps save precious minutes.

Images here are built for three architectures: `amd64`, `arm` , and `aarch64` (aka `arm64`). The latter two are built using `qemu` emulation.  For details see [here].

[lncm/bitcoind]: https://github.com/lncm/docker-bitcoind/
[here]: https://github.com/meeDamian/simple-qemu


## Pull

Pulling this image directly is only useful if you know exactly what you need it for, can be achieved with:

```bash
docker pull lncm/berkeleydb:db-4.8.30.NC
```

> **NOTE:** architecture is chosen automatically based on the CPU of the Docker host.

#### Manual

To manually specify the architecture, use one of the commands below.

```bash
docker pull lncm/berkeleydb:db-4.8.30.NC-arm
docker pull lncm/berkeleydb:db-4.8.30.NC-arm64
docker pull lncm/berkeleydb:db-4.8.30.NC-amd64
```

## Dockerfile

To build bitcoind w/o the need to rebuild Berkeleydb, you can do:

```dockerfile
# Start new stage to build _something_
FROM alpine AS something

# Copy all BDB relevant files to your stage
COPY  --from=lncm/berkeleydb:db-4.8.30.NC  /opt  /opt

# …
# continue with your instructions here 
```

