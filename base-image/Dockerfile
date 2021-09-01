FROM ubuntu:20.04

RUN sed -i '/history-search-backward/s/^# //g' /etc/inputrc \
  && sed -i '/history-search-forward/s/^# //g' /etc/inputrc \
  && echo "alias mc='mc -b'" > /etc/profile.d/00-aliases.sh \
  && sed -i '/%sudo/d' /etc/sudoers \
  && echo "%sudo   ALL=(ALL:ALL)  NOPASSWD: ALL" >> /etc/sudoers

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
  python3-netaddr \
  python3-pymysql \
  bsdmainutils \
  git
RUN pip3 install --upgrade cryptography \
  && pip3 install --upgrade azure-cli \
  && python3 -m easy_install --upgrade pyOpenSSL \
  && curl -L -o /tmp/azcopy.tgz -s https://aka.ms/downloadazcopy-v10-linux \
  && tar -zxf /tmp/azcopy.tgz -C /tmp \
  && mv /tmp/azcopy_linux_amd64_*/azcopy /usr/local/bin/ \
  && chmod 755 /usr/local/bin/azcopy
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - \
  && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
  && DEBIAN_FRONTEND=noninteractive apt update \
  && DEBIAN_FRONTEND=noninteractive apt -y install kubectl
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
  && apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && DEBIAN_FRONTEND=noninteractive apt update \
  && DEBIAN_FRONTEND=noninteractive apt -y install terraform packer vault consul
RUN TERRAGRUNT_VERSION=$(curl --silent "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")') \
  && curl -L -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
  && chmod +x /usr/local/bin/terragrunt
RUN SOPS_VERSION=$(curl --silent "https://api.github.com/repos/mozilla/sops/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
  && curl -LO https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb \
  && dpkg -i sops_${SOPS_VERSION}_amd64.deb && rm sops_${SOPS_VERSION}_amd64.deb
RUN AGE_VERSION=$(curl --silent "https://api.github.com/repos/FiloSottile/age/releases" | jq -r .[0].tag_name) \
  && curl -LO https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz \
  && tar -zxf age-${AGE_VERSION}-linux-amd64.tar.gz -C /tmp \
  && mv /tmp/age/age* /usr/local/bin/ \
  && rm -rf /tmp/age
RUN pip3 install ansible \
  && pip3 install --upgrade requests \
  && pip3 install ansible-modules-hashivault
