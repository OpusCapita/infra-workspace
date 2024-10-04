FROM opuscapita/andariel-devops:latest

ARG USERNAME
ARG UID
ARG GID

RUN sed -i '/history-search-backward/s/^# //g' /etc/inputrc ; \
  sed -i '/history-search-forward/s/^# //g' /etc/inputrc ; \
  groupadd -g $GID $USERNAME \
  && useradd -d /home/$USERNAME -m -s /bin/zsh -g $GID -u $UID $USERNAME \
  && usermod -aG sudo $USERNAME \
  && usermod -a -G docker $USERNAME

# ZSH

RUN sh -c "sudo apt install -y zsh; $(curl -s -L https://github.com/OpusCapita/zsh-in-docker/raw/master/zsh-in-docker.sh)" -- \
    -a 'CASE_SENSITIVE="true"' \
    -p git \
    -p https://github.com/zsh-users/zsh-completions \
    -a 'autoload -U history-search-end' \
    -a '[[ -n \${key[PageUp]} ]] && bindkey "\${key[PageUp]}" history-beginning-search-backward' \
    -a '[[ -n \${key[PageDown]} ]] && bindkey "\${key[PageDown]}" history-beginning-search-forward' \
    -a 'bindkey "\${terminfo[kLFT5]}" backward-word' \
    -a 'bindkey "\${terminfo[kRIT5]}" forward-word' \
    -a 'setopt HIST_IGNORE_ALL_DUPS' \
    -a 'setopt SHARE_HISTORY' \
    -a 'HISTSIZE=1000000' \
    -a 'SAVEHIST=10000000'

COPY zsh /opt/zsh

RUN cp  -rp "$HOME/.oh-my-zsh" /opt/zsh/

COPY bootstrap.sh /opt/

ENV DEBUG_COLORS=true
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
# END ZSH

USER $USERNAME
WORKDIR /home/$USERNAME
ENTRYPOINT ["/bin/bash","/opt/bootstrap.sh"]
