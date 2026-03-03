#!/bin/bash

set -eux
export DEBIAN_FRONTEND="noninteractive"
trap 'sudo rm -rf /workspace/**' EXIT
if [[ $EUID -ne 0 ]]; then
   exec sudo -E /bin/bash "$0" "$@"
fi

# install docker-ce
apt-get update
apt-get install --no-install-recommends -y ca-certificates curl gnupg zip unzip jq
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker $SETUP_USER
cp daemon.json /etc/docker/daemon.json

# alias dive trivy grype
cat bash_aliases >> /home/$SETUP_USER/.bash_aliases
chmod 777 /home/$SETUP_USER/.bash_aliases

# handy-sshd
wget -O /tmp/handdy.tar.gz https://github.com/nwtgck/handy-sshd/releases/download/v0.4.3/handy-sshd-0.4.3-linux-amd64.tar.gz
tar -xzf /tmp/handdy.tar.gz -C /tmp
cp /tmp/handy-sshd /usr/local/bin/
rm -rf /tmp/*
# static-bash
wget -O /usr/local/bin/bash-static https://github.com/robxu9/bash-static/releases/download/5.2.015-1.2.3-2/bash-linux-x86_64
# static-busybox
wget -O /tmp/main.zip https://github.com/shutingrz/busybox-static-binaries-fat/archive/refs/heads/main.zip
unzip /tmp/main.zip -d /tmp
mv /tmp/busybox-static-binaries-fat-main/busybox-x86_64-linux-gnu /usr/local/bin/busybox-static
rm -rf /tmp/*
rm -rf /home/$SETUP_USER/.wget-hsts

cp -rf scripts/* /usr/local/bin/
chmod -R 777 /usr/local/bin/

# proxy
mkdir -p /home/$SETUP_USER/.docker
cat config.json > /home/$SETUP_USER/.docker/config.json
chmod -R 777 /home/$SETUP_USER/.docker

echo "cleanup"
if [[ $EUID -ne 0 ]]; then
   exec sudo -E /bin/bash "$0" "$@"
fi
apt-get -y autoclean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/ /workspace/*
