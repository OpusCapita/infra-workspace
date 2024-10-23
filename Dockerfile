FROM opuscapita/toolbox:latest

# TODO: Add user interface tools
# https://www.youtube.com/watch?v=-TfcFqQAJiY

RUN true \
  && sed -i '/history-search-backward/s/^# //g' /etc/inputrc \
  && sed -i '/history-search-forward/s/^# //g' /etc/inputrc

COPY bootstrap.sh /opt/

ENV DEBUG_COLORS=true
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
# END ZSH

#USER $USERNAME
WORKDIR /home/$USERNAME
ENTRYPOINT ["/bin/bash","/opt/bootstrap.sh"]
