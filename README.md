# pollenjp-docker

- This repository provides VM-like docker containers.
- You can access to the container through SSH.
- Any username and user id can be set as the container's user at running `docker run` command.
  - It may be useful to set the same username and user id as the host machine

## ToC

<!-- TOC -->

- [ToC](#toc)
- [docker network](#docker-network)
- [pull containers from ghcr](#pull-containers-from-ghcr)
- [ssh login](#ssh-login)
- [Self-build](#self-build)
  - [docker build](#docker-build)

<!-- /TOC -->

## docker network

Create some private network to fix static IP.

```sh
docker network create \
    --driver=bridge \
    --subnet=172.20.0.0/16 \
    --gateway=172.20.255.254 \
    pollenjp-docker-net
```

## pull containers from ghcr

- `VERSION`: `latest` or release version like `0.1.9`
- You should wait about one minutes for some preprocessing by `entrypoint.sh`.

```sh
(
  VERSION="latest";
  IP_ADDRESS="172.20.0.1";
  CUDA_VERSION="9.2-cudnn7-devel";
  UBUNTU_VERSION="18.04";
  docker run \
    --detach \
    --restart always \
    --network "pollenjp-docker-net" \
    --ip "${IP_ADDRESS}" \
    --gpus all \
    --memory 14gb \
    --shm-size 14gb \
    --env NVIDIA_DRIVER_CAPABILITIES=all \
    --env "LOCAL_USER_NAME=$(id --user --name)" \
    --env "LOCAL_USER_ID=$(id --user)" \
    --env "LOCAL_GROUP_NAME=$(id --group --name)" \
    --env "LOCAL_GROUP_ID=$(id --group)" \
    --volume "${HOME}/workdir:${HOME}/workdir/" \
    --volume "${HOME}/.ssh:${HOME}/.ssh" \
    --volume "${HOME}:/mnt/host" \
    --volume "/media:/media" \
    --name "pollenjp-docker${VERSION}-cuda${CUDA_VERSION}-ubuntu${UBUNTU_VERSION}" \
    "ghcr.io/pollenjp/pollenjp-docker:${VERSION}-cuda${CUDA_VERSION}-ubuntu${UBUNTU_VERSION}"
)
```

## ssh login

- Default password is `password`
- At first login, the password is required to be changed.

```sh
ssh "$(id --user --name)"@172.20.0.1
```

## Self-build

### docker build

```sh
(
  CUDA_VERSION="9.2-cudnn7-devel";
  UBUNTU_VERSION="18.04";
  docker build \
    --network=host \
    --tag "pollenjp-docker-cuda${CUDA_VERSION}-ubuntu${UBUNTU_VERSION}" \
    --build-arg CUDA_VERSION="${CUDA_VERSION}" \
    --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
    --file "ubuntu${UBUNTU_VERSION}/Dockerfile" \
    "ubuntu${UBUNTU_VERSION}"
)
```
