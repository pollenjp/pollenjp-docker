# ssh-container

## ToC

<!-- TOC -->

- [ToC](#toc)
- [docker network](#docker-network)
- [Dockerfile](#dockerfile)
  - [minimum1](#minimum1)
- [test](#test)
- [network](#network)

<!-- /TOC -->

## docker network

```sh
docker network create \
    --driver=bridge \
    --subnet=172.20.0.0/16 \
    --gateway=172.20.255.254 \
    pollen-net
```

## Dockerfile

### minimum1

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
    | 11.2.2-cudnn8-devel | 20.04          |

  - build container

    ```sh
    make docker-build-base1-template \
      CUDA_VERSION=11.2.2-cudnn8-devel \
      UBUNTU_VERSION=20.04
    ```

  - run

    ```sh
    docker run \
      --detach \
      --restart=always \
      --network=<network> \
      --ip=172.20.<XXX>.<YYY> \
      --gpus all \
      --env NVIDIA_DRIVER_CAPABILITIES=all \
      --env LOCAL_USER_NAME="$(id --user --name)" \
      --env LOCAL_USER_ID="$(id --user)" \
      --env LOCAL_GROUP_NAME="$(id --group --name)" \
      --env LOCAL_GROUP_ID="$(id --group)" \
      --volume "${HOME}/workdir":"${HOME}/workdir/" \
      --volume /media:/media \
      --name=<container-name> \
      <docker-image-name>
    ```

## test

```sh
make create-test-docker-network
test-docker-base1-build-and-run
```

## network

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
