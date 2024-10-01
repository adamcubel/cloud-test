#!/bin/bash

dnf install -y \
    gcc \
    git \
    nano \
    jq \
    unzip \
    vim

# awscli
echo "Installing: awscli"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q "/tmp/awscliv2.zip" -d /tmp/install
sh /tmp/install/aws/install

# OpenTofu
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method rpm
rm -f install-opentofu.sh
ln -s /usr/bin/tofu /usr/bin/terraform

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install Homebrew
curl -fsSL -o k9s_linux_amd64.rpm https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.rpm
rpm -ivh k9s_linux_amd64.rpm
