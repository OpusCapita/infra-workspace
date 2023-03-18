#!/bin/bash
[[ ! -z "$SKIP_BOOTSTRAP" ]] && { exec /bin/zsh; exit $?; }

[[ ! -f "$HOME/.zshrc" ]] \
&& [[ ! -f "$HOME/.p10k.zsh" ]] \
&& [[ ! -d "$HOME/.oh-my-zsh" ]] \
&& {
  cp -r /opt/zsh/.zshrc /opt/zsh/.p10k.zsh /opt/zsh/.oh-my-zsh "$HOME"/
  [[ ! -f "$HOME/.histfile" ]] && cat "$HOME/.bash_history" > "$HOME/.histfile"
}
cd "$WORKDIR"
exec /bin/zsh