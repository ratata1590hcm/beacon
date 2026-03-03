#!/bin/bash

set -eux

# install cntlm
# apt-get update
# apt-get install cntlm

# cp cntlm.conf /etc/cntlm.conf
cat environment >> /etc/environment
cat bash_aliases >> /config/.bash_aliases
chmod 777 /config/.bash_aliases

cat >> ~/.bashrc << 'EOF'
# Load personal aliases if the file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF

# docker proxy
mkdir -p /etc/systemd/system/docker.service.d/
cp -rf docker/http.conf /etc/systemd/system/docker.service.d/http-proxy.conf
mkdir -p /root/.docker
cat docker/config.json > /root/.docker/config.json
chmod -R 777 /root/.docker
mkdir -p /config/.docker
cat docker/config.json > /config/.docker/config.json
chmod -R 777 /config/.docker

# patch autostart
# sudo cp -rf autostart/cntlm.desktop /etc/xdg/autostart/cntlm.desktop
# s6 autostart
sudo mkdir -p /etc/s6-overlay/s6-rc.d/cntlm
sudo cp -rf s6/* /etc/s6-overlay/s6-rc.d/cntlm/
mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d
touch /etc/s6-overlay/s6-rc.d/user/contents.d/cntlm

echo "cleanup"
apt-get -y autoclean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/ /workspace/*
