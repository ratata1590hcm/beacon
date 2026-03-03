#!/bin/bash
set -eux
export DEBIAN_FRONTEND=noninteractive
trap 'rm -rf /workspace/**' EXIT
if [[ $EUID -ne 0 ]]; then
   exec sudo -E /bin/bash "$0" "$@"
fi

# terragrunt
curl -SL https://github.com/gruntwork-io/terragrunt/releases/download/v0.99.4/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt && chmod 777 /usr/local/bin/terragrunt

# aws cli
curl -sL --insecure "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

apt-get update
apt-get install -y python3-pip
pip3 install --break-system-packages git-remote-codecommit boto3 ruamel.yaml PyYAML

# azure cli
curl -sL --insecure https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
    && AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ ${AZ_REPO} main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y azure-cli \
    && rm -rf /var/lib/apt/lists/*

# tfenv
git clone --depth=1 https://github.com/tfutils/tfenv.git /home/$SETUP_USER/.tfenv
chmod 777 -R /home/$SETUP_USER/.tfenv
rm -rf /home/$SETUP_USER/.tfenv/.git
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> /home/$SETUP_USER/.bash_profile

# config envs
cat environment >> /etc/environment
cat bash_aliases >> /home/$SETUP_USER/.bash_aliases
chmod 777 /home/$SETUP_USER/.bash_aliases

echo "cleanup"
apt-get -y autoclean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/ /workspace/*
