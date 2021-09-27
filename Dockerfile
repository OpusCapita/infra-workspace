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
  net-tools \
  iputils-ping \
  lsb-release \
  gnupg \
  dnsutils \
  whois \
  ipcalc \
  sshpass \
  vim \
  && echo "alias mc='mc -b'" > /etc/profile.d/00-aliases.sh \
  && sed -i '/%sudo/d' /etc/sudoers \
  && echo "%sudo   ALL=(ALL:ALL)  NOPASSWD: ALL" >> /etc/sudoers \
  && apt install -y --no-install-recommends python-netaddr
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
  && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
  && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
  && apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && DEBIAN_FRONTEND=noninteractive apt update \
  && DEBIAN_FRONTEND=noninteractive apt -y install kubectl git terraform
RUN pip3 install ansible
RUN pip3 install --upgrade cryptography \
  && pip3 install --upgrade azure-cli \
  && python3 -m easy_install --upgrade pyOpenSSL \
  && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN PACKER_VERSION=$(curl -s https://releases.hashicorp.com/packer/ | grep packer_ | cut -d / -f 3 | head -n 1) \
  && curl -O https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
  && unzip -d /usr/local/bin packer_${PACKER_VERSION}_linux_amd64.zip
RUN TERRAGRUNT_VERSION=$(curl --silent "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")') \
  && curl -L -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
  && chmod +x /usr/local/bin/terragrunt
RUN curl -L -o /tmp/azcopy.tgz -s https://aka.ms/downloadazcopy-v10-linux \
  && tar -zxf /tmp/azcopy.tgz -C /tmp \
  && mv /tmp/azcopy_linux_amd64_*/azcopy /usr/local/bin/ \
  && chmod 755 /usr/local/bin/azcopy
# fixes azure-cli dependencies
RUN python3 -m pip install --upgrade requests; python3 -m pip install ansible-modules-hashivault
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install bsdmainutils
RUN SOPS_VERSION=$(curl --silent "https://api.github.com/repos/mozilla/sops/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
  && curl -LO https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb \
  && dpkg -i sops_${SOPS_VERSION}_amd64.deb && rm sops_${SOPS_VERSION}_amd64.deb
RUN AGE_VERSION=$(curl --silent "https://api.github.com/repos/FiloSottile/age/releases" | jq -r .[0].tag_name) \
  && curl -LO https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz \
  && tar -zxf age-${AGE_VERSION}-linux-amd64.tar.gz -C /tmp \
  && mv /tmp/age/age* /usr/local/bin/ \
  && rm -rf /tmp/age
RUN pip3 install pymysql
RUN pip3 install netaddr

ARG USERNAME
ARG UID
ARG GID
RUN sed -i '/history-search-backward/s/^# //g' /etc/inputrc ; \
  sed -i '/history-search-forward/s/^# //g' /etc/inputrc ; \
  groupadd -g $GID $USERNAME \
  && useradd -d /home/$USERNAME -m -s /bin/bash -g $GID -u $UID $USERNAME \
  && usermod -aG sudo $USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME
ENTRYPOINT ["/bin/sh","-c","cd \"$WORKDIR\"; exec /bin/bash"]
