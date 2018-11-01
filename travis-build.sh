#!/bin/bash
set -e

mkdir -p ~/.docker
echo '{ "experimental": "enabled" }' > ~/.docker/config.json

sudo systemctl restart docker

wget -N https://github.com/multiarch/qemu-user-static/releases/download/v3.0.0/x86_64_qemu-arm-static.tar.gz
tar -xvf x86_64_qemu-arm-static.tar.gz

docker run --rm --privileged multiarch/qemu-user-static:register

sed -ie 's/FROM alpine/FROM arm32v6\/alpine/g' Dockerfile

docker build --no-cache -t berkeleydb .
