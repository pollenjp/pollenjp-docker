#!/usr/bin/zsh -eux

USER_NAME=${LOCAL_USER_NAME}
USER_ID=${LOCAL_USER_ID:-1000}
GROUP_NAME=${LOCAL_GROUP_NAME}
GROUP_ID=${LOCAL_GROUP_ID:-1000}

export HOME=/home/${USER_NAME}

# Run command in Docker Container only on the first start - Stack Overflow
# https://stackoverflow.com/a/50638207/9316234>
CONTAINER_ALREADY_STARTED=/CONTAINER_ALREADY_STARTED_PLACEHOLDER.txt

if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"

    ###############
    # create user #
    ###############

    useradd \
        --create-home \
        --home /home/${USER_NAME} \
        --uid ${USER_ID} \
        --shell /usr/bin/zsh \
        ${USER_NAME}
    /usr/sbin/gosu ${USER_NAME} ls -la ${HOME}
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME} \
    # setting password
    echo "${USER_NAME}:password" | chpasswd
    passwd --expire ${USER_NAME}
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

    ############################
    # pyenv & pyenv-virtualenv #
    ############################

    # pyenv
    /usr/sbin/gosu ${USER_NAME} git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv

    # Set variable and Init pyenv
    # write in ~/.zshrc
    /usr/sbin/gosu ${USER_NAME} \
        echo 'export PYENV_ROOT="$HOME/.pyenv"' \
        | /usr/sbin/gosu ${USER_NAME} \
        tee --append ${HOME}/.zshrc
    /usr/sbin/gosu ${USER_NAME} \
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' \
        | /usr/sbin/gosu ${USER_NAME} \
        tee --append ${HOME}/.zshrc
    /usr/sbin/gosu ${USER_NAME} \
        echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' \
        | /usr/sbin/gosu ${USER_NAME} \
        tee --append ${HOME}/.zshrc
    # execute
    PYENV_ROOT="$HOME/.pyenv"
    PATH="${PYENV_ROOT}/bin:${PATH}"
    /usr/sbin/gosu ${USER_NAME} pyenv init -

    # pyenv-virtuaenv
    # <https://github.com/pyenv/pyenv-virtualenv>
    /usr/sbin/gosu ${USER_NAME} \
        git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
    /usr/sbin/gosu ${USER_NAME} \
        echo 'eval "$(pyenv virtualenv-init -)"' \
        | /usr/sbin/gosu ${USER_NAME} \
        tee --append ${HOME}/.zshrc
else
    echo "-- Not first container startup --"
fi

exec /usr/bin/supervisord
