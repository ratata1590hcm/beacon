#!/bin/bash

set -eux

cat environment >> /etc/environment
cat bash_aliases >> /home/$SETUP_USER/.bash_aliases
chmod 777 /home/$SETUP_USER/.bash_aliases

# patch docker proxy initd
cat bash_aliases >> /etc/default/docker

echo "cleanup"
apt-get -y autoclean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/ /workspace/*
