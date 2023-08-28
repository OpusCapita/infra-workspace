FROM ubuntu:20.04

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
  sudo \
  curl \
  nano \
  mc \
  unzip \
  pigz \
  ca-certificates \
  openssh-client \
  software-properties-common \
  apt-transport-https \
  python3-pip \
  jq \
  cowsay \
  locales \
  python3-jmespath \
  python3-requests \
  python-is-python3 \
  net-tools \
  iputils-ping \
  lsb-release \
  gnupg \
  dnsutils \
  whois \
  ipcalc \
  sshpass \
  vim \
  bsdmainutils \
  moreutils \
  && echo "alias mc='mc -b'" > /etc/profile.d/00-aliases.sh \
  && sed -i '/%sudo/d' /etc/sudoers \
  && echo "%sudo   ALL=(ALL:ALL)  NOPASSWD: ALL" >> /etc/sudoers \
  && apt install -y --no-install-recommends python-netaddr

# Ansible and azure CLI
RUN pip3 install ansible \
  && pip3 install --upgrade cryptography \
  && pip3 install --upgrade azure-cli \
  && python3 -m easy_install --upgrade pyOpenSSL \
  && python3 -m pip install --upgrade requests \
  && python3 -m pip install ansible-modules-hashivault==4.7.0 \
  && python3 -m pip install hvac==0.11.2 \
  && pip3 install pymysql \
  && pip3 install netaddr

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
  && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
  && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
  && apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && DEBIAN_FRONTEND=noninteractive apt update \
  && DEBIAN_FRONTEND=noninteractive apt -y install kubectl git terraform
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN PACKER_VERSION=$(curl -s https://releases.hashicorp.com/packer/ | grep packer | cut -d "_" -f2 | cut -d "<" -f1 | head -n 1) \
  && curl -O https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
  && unzip -d /usr/local/bin packer_${PACKER_VERSION}_linux_amd64.zip
RUN TERRAGRUNT_VERSION=$(curl --silent "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")') \
  && curl -L -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
  && chmod +x /usr/local/bin/terragrunt
RUN curl -L -o /tmp/azcopy.tgz -s https://aka.ms/downloadazcopy-v10-linux \
  && tar -zxf /tmp/azcopy.tgz -C /tmp \
  && mv /tmp/azcopy_linux_amd64_*/azcopy /usr/local/bin/ \
  && chmod 755 /usr/local/bin/azcopy
RUN SOPS_VERSION=$(curl --silent "https://api.github.com/repos/getsops/sops/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
  && curl -LO https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb \
  && dpkg -i sops_${SOPS_VERSION}_amd64.deb && rm sops_${SOPS_VERSION}_amd64.deb
RUN AGE_VERSION=$(curl --silent "https://api.github.com/repos/FiloSottile/age/releases" | jq -r .[0].tag_name) \
  && curl -LO https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz \
  && tar -zxf age-${AGE_VERSION}-linux-amd64.tar.gz -C /tmp \
  && mv /tmp/age/age* /usr/local/bin/ \
  && rm -rf /tmp/age
RUN HELMIFY_VERSION=$(curl --silent "https://api.github.com/repos/arttor/helmify/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
  && curl -LO https://github.com/arttor/helmify/releases/download/v${HELMIFY_VERSION}/helmify_Linux_x86-64.tar.gz \
  && tar -zxf hhelmify_Linux_x86-64.tar.gz -C /tmp \
  && mv /tmp/helmify /usr/local/bin/ \
  && rm -rf /tmp/helmify
RUN curl -LO https://github.com/vmware-tanzu/velero/releases/download/v1.10.0/velero-v1.10.0-linux-amd64.tar.gz \
  && tar -zxf velero-v1.10.0-linux-amd64.tar.gz -C /tmp \
  && mv /tmp/velero-v1.10.0-linux-amd64/velero /usr/local/bin/ \
  && rm -rf /tmp/velero-v1.10.0-linux-amd64

ARG USERNAME
ARG UID
ARG GID
RUN sed -i '/history-search-backward/s/^# //g' /etc/inputrc ; \
  sed -i '/history-search-forward/s/^# //g' /etc/inputrc ; \
  groupadd -g $GID $USERNAME \
  && useradd -d /home/$USERNAME -m -s /bin/zsh -g $GID -u $UID $USERNAME \
  && usermod -aG sudo $USERNAME

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

COPY .p10k.zsh /opt/zsh/
COPY zshrc.zsh /opt/zsh/.zshrc

RUN cp  -rp "$HOME/.oh-my-zsh" /opt/zsh/

COPY bootstrap.sh /opt/

ENV DEBUG_COLORS=true
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
# END ZSH

USER $USERNAME
WORKDIR /home/$USERNAME
ENTRYPOINT ["/bin/bash","/opt/bootstrap.sh"]
#ENTRYPOINT ["/bin/sh","-c","cd \"$WORKDIR\"; exec /bin/zsh"]
