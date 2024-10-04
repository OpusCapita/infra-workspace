#!/bin/bash 

export MY_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export MY_HOMEPATH="$( cd >/dev/null 2>&1 && pwd )"
export MY_PARENT=$(dirname "${MY_PATH}")
export CONTAINER_NAME="${MY_PARENT}"

export xUID=$(id -u)
export xGID=$(id -g)
[[ -z "$USERNAME" ]] && export USERNAME="$USER"

export BUILDKIT_PROGRESS=plain

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Windows;;
    MINGW*)     machine=Windows;;
    *)          machine="UNKNOWN:${unameOut}"
esac

if [ "$machine" == "Windows" ] ; then
  WINPTY="winpty"
else
  if [ $(id -u) -eq "0" ]; then
    echo "Doesn't work when launched as root."
    exit 1
  fi

  SUDO="sudo -EHu app"
  if ! type docker-compose >/dev/null 2>&1; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  fi
fi

pushd "$MY_PATH"
if [ "$1" == "build" ]; then
  if [ "$2" == "base" ]; then
    cd base-image
    docker build -t opuscapita/andariel-devops:latest . || exit 1
    cd ..
  fi
  docker-compose --ansi=never build && \
  exec $WINPTY docker-compose --ansi=never run --rm -e TERM -e COLORTERM main
else
  exec $WINPTY docker-compose --ansi=never run --rm -e TERM -e COLORTERM main
fi
popd
