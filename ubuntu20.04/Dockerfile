ARG CUDA_VERSION
ARG UBUNTU_VERSION=20.04

FROM nvidia/cuda:${CUDA_VERSION}-ubuntu${UBUNTU_VERSION}
# <https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=cudnn8-devel-ubuntu18.04&ordering=last_updated>

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND "noninteractive"
ENV TZ "Asia/Tokyo"

RUN apt-get update -y \
    && \
    apt-get install -y --no-install-recommends \
    # essential
    apt-utils \
    aptitude \
    build-essential \
    gosu \
    locales \
    # ssh and supervisor
    openssh-server \
    supervisor \
    # sudo for users
    sudo \
    # need tools
    cmake \
    make \
    git \
    screen \
    vim \
    zsh \
    unzip \
    # Japanese
    language-pack-ja-base \
    language-pack-ja \
    ibus-mozc \
    locales \
    locales-all \
    silversearcher-ag \
    # google noto font
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    && \
    # Japanese
    locale-gen ja_JP.UTF-8 \
    && \
    ######################
    # pyenv requirements #
    ######################
    # <https://github.com/pyenv/pyenv/wiki/common-build-problems>
    apt-get install -y \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    && \
    #########
    # clean #
    #########
    apt-get clean

SHELL ["/usr/bin/zsh", "-c"]

# ssh & supervisor
RUN mkdir -p /var/run/sshd /var/log/supervisor

USER root
WORKDIR /
ENV HOME /

ARG DOCKERFILE_DIR=.

EXPOSE 22
# supervisor
# <https://docs.docker.jp/engine/admin/using_supervisord.html
COPY ${DOCKERFILE_DIR}/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# entrypoint
COPY ${DOCKERFILE_DIR}/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
