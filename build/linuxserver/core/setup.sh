#!/bin/bash
set -eux
export DEBIAN_FRONTEND=noninteractive
cp -rf apt-99disable-ssl-verify.conf /etc/apt/apt.conf.d/99disable-ssl-verify.conf
apt-get update
apt-get install -y tini nmap ncdu net-tools wget sudo htop nano btop nvtop tmux proot rsync

usermod -aG sudo $SETUP_USER
echo "$SETUP_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$SETUP_USER
chmod 0440 /etc/sudoers.d/$SETUP_USER
chmod -R 777 ~
mkdir -p /config
touch /config/.gitcontext
chmod -R 777 /config
chown $SETUP_USER /config
ln -s /config /home/$SETUP_USER
chmod -R 777 /home/$SETUP_USER
chown $SETUP_USER /home/$SETUP_USER
find /config -type d -name ".git" -prune -exec rm -rf {} +
sed -i 's/^root:x:/root::/' /etc/passwd
sed -i 's/^root:[^:]*:/root::/' /etc/shadow

apt-get -y autoclean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/ /workspace/*
