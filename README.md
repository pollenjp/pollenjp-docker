# ssh-container

## 1. ToC

<!-- TOC -->

- [1. ToC](#1-toc)
- [2. docker network](#2-docker-network)
- [3. Dockerfile](#3-dockerfile)
  - [3.1. minimum1](#31-minimum1)
  - [3.2. minimum2](#32-minimum2)
- [4. test](#4-test)
- [5. network](#5-network)

<!-- /TOC -->

## 2. docker network

```sh
docker network create \
    --driver=bridge \
    --subnet=172.20.0.0/16 \
    --gateway=172.20.255.254 \
    pollenjp-docker-net
```

## 3. Dockerfile

### 3.1. minimum1

- build 時には user 以下を作成せず, run 時に `ENTRYPOINT` の shell script を元に user 以下を作成する.
- example
  - test

    ```sh
    make test-docker-base1-build-and-run
    ```

- run
  - compatible table

    | CUDA_VERSION        | UBUNTU_VERSION |
    |---------------------|----------------|
    | 9.2-cudnn7-devel    | 18.04          |
    | 10.1-cudnn8-devel   | 18.04          |
    | 11.1-cudnn8-devel   | 18.04          |
    | 11.1.1-cudnn8-devel | 18.04          |

  - build container

    ```sh
    make docker-build-base1-cuda11.2.2-cudnn8-devel-ubuntu18.04
    ```

    ```sh
    make docker-build-base1 \
      DOCKERFILE_DIR=./base1 \
      CUDA_VERSION=9.2-cudnn7-devel \
      UBUNTU_VERSION=18.04
    ```

  - run

    ```sh
    docker run \
      --detach \
      --restart=always \
      --network=<network> \
      --ip=172.20.0.XXX \
      --gpus all \
      --env NVIDIA_DRIVER_CAPABILITIES=all \
      --env LOCAL_USER_NAME=$(id --user --name) \
      --env LOCAL_USER_ID=$(id --user) \
      --env LOCAL_GROUP_NAME=$(id --group --name) \
      --env LOCAL_GROUP_ID=$(id --group) \
      --volume ${HOME}/workdir:${HOME}/workdir/ \
      --volume /media:/media \
      --name=<container-name> \
      <docker-image-name>
    ```

    - example

      ```sh
      docker run \
          --detach \
          --restart=always \
          --network=pollenjp-docker-net \
          --ip=172.20.0.XX \
          --gpus all \
          --env NVIDIA_DRIVER_CAPABILITIES=all \
          --env LOCAL_USER_NAME=$(id --user --name) \
          --env LOCAL_USER_ID=$(id --user) \
          --env LOCAL_GROUP_NAME=$(id --group --name) \
          --env LOCAL_GROUP_ID=$(id --group) \
          --volume ${HOME}/workdir:${HOME}/workdir/ \
          --volume /media:/media \
          --name=pollen01 \
          pollenjp-docker-base1-cuda11.2.2-cudnn8-devel-ubuntu18.04
      ```

### 3.2. minimum2

- container で user 以下に pyenv を生成してから, user ディレクトリ以下のUID等を変更する

## 4. test

```sh
make create-test-docker-network
test-docker-base1-build-and-run
```

## 5. network

```sh
 % docker network create --driver=bridge --subnet=172.20.0.0/16 --gateway=172.20.255.254 xxx-net
```

docker imageをrunする際にネットワークと固定するIPを指定 (`--network="xxx-net" --ip=172.20.xxx.xxx`)

注意

- `--subnet`と`--gateway`を両方指定してnetworkを作成しないと以下のようなエラーがでる

```sh
 % docker run --network="xxx-net" --ip=172.20.xxx.xxx ...
docker: Error response from daemon: user specified IP address is supported only when connecting to networks with user configured subnets.
```
