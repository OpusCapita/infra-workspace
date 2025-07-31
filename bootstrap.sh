#!/bin/bash
#set -e

export HOME=/home/$USERNAME


# Create group for docker, respecting the GID of the docker socket
# If group is already in use and it's not docker
CUR_GROUP=$(getent group $GID_DOCKER | cut -f1 -d:)
if getent group $GID_DOCKER >/dev/null && [ "$CUR_GROUP" != "docker" ]; then
    # delete user with default group set to $GID_DOCKER
    # echo deleting user with default group \'$CUR_GROUP\' from the image
    USER_DEL=$(getent passwd | awk -F: '$4 == '$GID_DOCKER' {print $1}')
    if [ ! -z "$USER_DEL" ]; then
        # echo deleting user \'$USER_DEL\' from the image
        userdel $(getent passwd | awk -F: '$4 == '$GID_DOCKER' {print $1}')
    fi
    if getent group $GID_DOCKER >/dev/null; then
        # echo deleting group \'$(getent group $GID_DOCKER | cut -f1 -d:)\' from the image
        groupdel $(getent group $GID_DOCKER | cut -f1 -d:)
    fi
    if getent group docker >/dev/null; then
        # echo deleting group docker from the image since it has wrong GID
        groupdel docker
    fi

    # echo adding docker group with GID $GID_DOCKER
    groupadd -g $GID_DOCKER docker
fi

getent passwd $UID > /dev/null && userdel $(getent passwd $UID | cut -f1 -d:) || true
getent group $GID  > /dev/null && groupdel $(getent group $GID | cut -f1 -d:) || true
groupadd -g $GID $USERNAME
useradd -d $HOME -M -s /bin/zsh -g $GID -u $UID $USERNAME
usermod -aG sudo $USERNAME
usermod -aG docker $USERNAME

cd "$WORKDIR"

[[ -f "$WORKDIR/one_password_secret.sh" ]] && source "$WORKDIR/one_password_secret.sh" || echo "No one_password_secret.sh found.
File should contain:
'''
export OP_CONNECT_HOST=http://opconnect.aks.dev.bnp.it.opuscapita.com:8080
export OP_CONNECT_TOKEN=<<< find in onepassword: Andariel/bnp-one-password, field: token >>>
'''
one_password_secret.sh should be in the root of the repo: $WORKDIR/one_password_secret.sh
"

[[ ! -f "$HOME/.zshrc" && ! -f "$HOME/.start_zsh" ]]  && { exec sudo -Eu $USERNAME "PATH=$PATH" /bin/bash; exit $?; }

bootstrap() {
  cp -r /opt/zsh/.zshrc /opt/zsh/.p10k.zsh /opt/zsh/.oh-my-zsh "$HOME"/
  [[ ! -f "$HOME/.histfile" ]] && cat "$HOME/.bash_history" > "$HOME/.histfile"
}

[[ ! -f "$HOME/.zshrc" ]] \
&& [[ ! -f "$HOME/.p10k.zsh" ]] \
&& [[ ! -d "$HOME/.oh-my-zsh" ]] \
&& {
  bootstrap
}

[[ -f "$HOME/.start_zsh" ]] && bootstrap && rm -f "$HOME/.start_zsh"
exec sudo -Eu $USERNAME "PATH=$PATH" /bin/zsh
