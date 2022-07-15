#!/bin/bash -eux

USER_ID=${LOCAL_UID:-1000}
GROUP_ID=${LOCAL_GID:-1000}
BASE_USER_NAME="baseuser"

echo "Changing IDs to (UID : ${USER_ID}, GID: ${GROUP_ID})"
usermod \
    -o \
    -u $USER_ID \
    -m --home /home/${BASE_USER_NAME} \
    ${BASE_USER_NAME}
groupmod -g ${GROUP_ID} ${BASE_USER_NAME}
echo "Changed!!"

exec /usr/bin/supervisord
