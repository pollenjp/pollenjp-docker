#!/bin/bash
set -eux

USER_NAME="${LOCAL_USER_NAME}"
USER_ID="${LOCAL_USER_ID:-1000}"
GROUP_ID="${LOCAL_GROUP_ID:-1000}"

export HOME="/home/${USER_NAME}"

# Run command in Docker Container only on the first start - Stack Overflow
# https://stackoverflow.com/a/50638207/9316234>
CONTAINER_ALREADY_STARTED=/CONTAINER_ALREADY_STARTED_PLACEHOLDER.txt

if [[ ! -e "$CONTAINER_ALREADY_STARTED" ]]; then
    touch "$CONTAINER_ALREADY_STARTED"
    echo "-- First container startup --"

    ###############
    # create user #
    ###############

    useradd \
        --create-home \
        --home "/home/${USER_NAME}" \
        --uid "${USER_ID}" \
        --shell /usr/bin/zsh \
        "${USER_NAME}"
    /usr/sbin/gosu "${USER_NAME}" ls -la "${HOME}"
    chown -R "${USER_NAME}:${GROUP_ID}" "/home/${USER_NAME}" \
    # setting password
    echo "${USER_NAME}:password" | chpasswd
    passwd --expire "${USER_NAME}"
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

else
    echo "-- Not first container startup --"
fi

exec /usr/bin/supervisord
