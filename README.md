# pollenjp-docker

## ToC

<!-- TOC -->

- [ToC](#toc)
- [docker network](#docker-network)
- [pull containers from ghcr](#pull-containers-from-ghcr)
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

```sh
(
  VERSION="0.1.4";
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
