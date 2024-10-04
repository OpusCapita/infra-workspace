FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update
RUN apt-get -y install \
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
      jq \
      cowsay \
      locales \
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
  && echo "%sudo   ALL=(ALL:ALL)  NOPASSWD: ALL" >> /etc/sudoers

# Ansible and azure CLI
RUN true \
  && apt-get install -y \
      python3-pip \
      python3-jmespath \
      python3-requests \
      python-is-python3 \
  && python3 -m pip install --upgrade pip \
  && pip3 install ansible \
  && pip3 install --upgrade cryptography \
  && pip3 install --upgrade azure-cli \
  && pip3 install pymysql \
  && pip3 install netaddr \
  && python3 -m easy_install --upgrade pyOpenSSL \
  && python3 -m pip install --upgrade requests \
  && python3 -m pip install ansible-modules-hashivault==4.7.0
RUN python3 -m pip install hvac==0.11.2

RUN true \
  && sudo mkdir -p /etc/apt/keyrings/ \
  && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
  && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
  && curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
  && apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && apt -y install kubectl git terraform vault
RUN true \
  && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN true \
  && PACKER_VERSION=$(curl -s https://releases.hashicorp.com/packer/ | grep packer | cut -d "_" -f2 | cut -d "<" -f1 | head -n 1) \
  && curl -O https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
  && unzip -d /usr/local/bin packer_${PACKER_VERSION}_linux_amd64.zip
RUN true \
  && TERRAGRUNT_VERSION=$(curl --silent "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")') \
  && curl -L -o /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
  && chmod +x /usr/local/bin/terragrunt
RUN true \
  && curl -L -o /tmp/azcopy.tgz -s https://aka.ms/downloadazcopy-v10-linux \
  && tar -zxf /tmp/azcopy.tgz -C /tmp \
  && mv /tmp/azcopy_linux_amd64_*/azcopy /usr/local/bin/ \
  && chmod 755 /usr/local/bin/azcopy
RUN true \
  && SOPS_VERSION=$(curl --silent "https://api.github.com/repos/getsops/sops/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
  && curl -LO https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb \
  && dpkg -i sops_${SOPS_VERSION}_amd64.deb && rm sops_${SOPS_VERSION}_amd64.deb
RUN true \
  && AGE_VERSION=$(curl --silent "https://api.github.com/repos/FiloSottile/age/releases" | jq -r .[0].tag_name) \
  && curl -LO https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz \
  && tar -zxf age-${AGE_VERSION}-linux-amd64.tar.gz -C /tmp \
  && mv /tmp/age/age* /usr/local/bin/ \
  && rm -rf /tmp/age
RUN true \
  && HELMIFY_VERSION=$(curl --silent "https://api.github.com/repos/arttor/helmify/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
  && curl -LO https://github.com/arttor/helmify/releases/download/v${HELMIFY_VERSION}/helmify_Linux_x86_64.tar.gz \
  && tar -zxf helmify_Linux_x86_64.tar.gz -C /tmp \
  && mv /tmp/helmify /usr/local/bin/ \
  && rm -rf /tmp/helmify
RUN true \
  && curl -LO https://github.com/vmware-tanzu/velero/releases/download/v1.10.0/velero-v1.10.0-linux-amd64.tar.gz \
  && tar -zxf velero-v1.10.0-linux-amd64.tar.gz -C /tmp \
  && mv /tmp/velero-v1.10.0-linux-amd64/velero /usr/local/bin/ \
  && rm -rf /tmp/velero-v1.10.0-linux-amd64
RUN true \
  && HETZNERK3S_VERSION=$(curl --silent "https://api.github.com/repos/vitobotta/hetzner-k3s/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
  && curl -o /usr/local/bin/hetzner-k3s -L https://github.com/vitobotta/hetzner-k3s/releases/download/v${HETZNERK3S_VERSION}/hetzner-k3s-linux-amd64 \
  && chmod 755 /usr/local/bin/hetzner-k3s
RUN true \
  && HCLOUD_VERSION=$(curl --silent "https://api.github.com/repos/hetznercloud/cli/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') \
  && curl -o /tmp/hcloud-linux-386.tar.gz -L https://github.com/hetznercloud/cli/releases/download/v${HCLOUD_VERSION}/hcloud-linux-386.tar.gz \
  && tar -zxf /tmp/hcloud-linux-386.tar.gz -C /tmp \
  && mv /tmp/hcloud /usr/local/bin/ \
  && rm -rf /tmp/*
RUN true \
  && curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  && chmod +x /usr/local/bin/yq
RUN true \
  && curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

RUN curl -fsSL https://get.docker.com | sh

COPY --from=1password/op:2 /usr/local/bin/op /usr/local/bin/op
