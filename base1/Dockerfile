
# CUDA_VERSION
# * 11.1.1-devel
# * 11.1.1-cudnn8-devel
ARG CUDA_VERSION
# UBUNTU_VERSION
# * 16.04
# * 18.04
ARG UBUNTU_VERSION

FROM nvidia/cuda:${CUDA_VERSION}-ubuntu${UBUNTU_VERSION}
# <https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=cudnn8-devel-ubuntu18.04&ordering=last_updated>

####################
# install packages #
####################

SHELL ["/bin/bash", "-c"]

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
    # clean
    apt-get clean

SHELL ["/usr/bin/zsh", "-c"]

# ssh & supervisor
RUN mkdir -p /var/run/sshd /var/log/supervisor

# <https://stackoverflow.com/questions/36292317/why-set-visible-now-in-etc-profile>
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

######################
# pyenv requirements #
######################

# * tk-dev
#   * setting for `tzdata`
#   * <https://serverfault.com/a/84528>
#   * <https://qiita.com/yagince/items/deba267f789604643bab>
ENV DEBIAN_FRONTEND "noninteractive"
RUN echo Asia/Tokyo > /etc/timezone
# * <https://github.com/pyenv/pyenv/wiki/common-build-problems>
RUN apt-get update -y \
    && \
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
    apt-get clean

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
# ENTRYPOINT ["/usr/bin/supervisord"]
