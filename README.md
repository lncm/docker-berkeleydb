# lncm/berkeleydb

[![](https://github.com/lncm/docker-berkeleydb/workflows/Build%20%26%20deploy%20on%20git%20tag%20push/badge.svg)][gh-actions]
[![](https://img.shields.io/microbadger/image-size/lncm/berkeleydb.svg?style=flat)][docker-hub]
[![](https://img.shields.io/docker/pulls/lncm/berkeleydb.svg?style=flat)][docker-hub]

[gh-actions]: https://github.com/lncm/docker-berkeleydb/actions
[docker-hub]: https://hub.docker.com/r/lncm/berkeleydb

This is the base image for [lncm/bitcoind] Docker images that rely on Berkeleydb version `db-4.8.30.NC`.  This stage is separated from the main bitcoind build process for two reasons:

1. BDB never changes and is only useful when bitcoind is compiled with wallet support enabled,
1. `qemu`-emulated builds take a very long time, separating out this part of the build helps save precious minutes.

Images here are built for three architectures: `amd64`, `arm32v7` , and `aarch64` (aka `arm64v8`). The latter two are built using `qemu` emulation.  For details see [here].

[lncm/bitcoind]: https://github.com/lncm/docker-bitcoind/
[here]: https://github.com/meeDamian/simple-qemu


## Pull

Pulling this image directly is only useful if you know exactly what you need it for, can be achieved with:

```bash
docker pull lncm/berkeleydb:v4.8.30.NC
```

> **NOTE:** architecture is chosen automatically based on the CPU of the Docker host.

#### Manual

To manually specify the architecture, use one of the commands below.

```bash
docker pull lncm/berkeleydb:v4.8.30.NC-amd64
docker pull lncm/berkeleydb:v4.8.30.NC-arm32v7
docker pull lncm/berkeleydb:v4.8.30.NC-arm64v8
```

## Dockerfile

To build bitcoind w/o the need to rebuild Berkeleydb, you can do:

```dockerfile
# Start new stage to build _something_
FROM alpine AS something

# Copy all BDB relevant files to your stage
COPY  --from=lncm/berkeleydb:v4.8.30.NC  /opt  /opt

# …
# continue with your instructions here 
```

