# ssh-container

## ToC

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
          --network=pollen-net \
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

### minimum2

- container で user 以下に pyenv を生成してから, user ディレクトリ以下のUID等を変更する

## test

```sh
make create-test-docker-network
test-docker-base1-build-and-run
```
