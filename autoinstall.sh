#!/bin/bash -e
#
# bash -c "$(curl https://github.com/OpusCapita/infra-workspace/raw/master/autoinstall.sh -H 'Cache-Control: no-cache' -L -s)" -- clean
#

if [[ "$1" == "clean" ]]; then
  rm -rf "$HOME/.oh-my-zsh"
  rm -rf "$HOME/.zshrc"
  rm -rf "$HOME/.p10k.zsh"
fi

# Install zsh.
sudo apt install -y zsh;

## todo: get files locally to this repo instead of fetching it from internet

# powerlevel10k
sh -c "$(curl -s -L https://github.com/OpusCapita/zsh-in-docker/raw/OC/zsh-in-docker.sh)" -- \
    -a 'CASE_SENSITIVE="true"' \
    -p git \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

# get & overwrite zsh config
curl https://github.com/OpusCapita/infra-workspace/raw/master/zshrc.zsh -H "Cache-Control: no-cache"  -L > ~/.zshrc

# get powerlevel10k config
curl https://github.com/OpusCapita/infra-workspace/raw/master/.p10k.zsh -H "Cache-Control: no-cache"  -L > ~/.p10k.zsh

# preserve your history
[[ ! -f "$HOME/.histfile" ]] && cat "$HOME/.bash_history" > "$HOME/.histfile"

# set as default
sudo usermod --shell /bin/zsh $USER

echo "Relogin for changes to take effect."
