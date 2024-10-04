#!/bin/bash

[[ -f "$WORKDIR/one_password_secret.sh" ]] && source "$WORKDIR/one_password_secret.sh"

[[ ! -f "$HOME/.zshrc" ]]  && { exec /bin/bash; exit $?; }

[[ ! -z "$SKIP_BOOTSTRAP" ]] && { exec /bin/zsh; exit $?; }

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

[[ -f "$HOME/.start_ssh" ]] && bootstrap && rm -f "$HOME/.start_ssh"

cd "$WORKDIR"
exec /bin/zsh