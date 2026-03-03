#!/bin/bash

set -eux
trap 'sudo rm -rf /workspace/**' EXIT

# apt-get update && apt-get install -y wget policykit-1
# wget -O bleachbit.deb https://download.bleachbit.org/bleachbit_5.0.2-0_all_ubuntu2404.deb
# apt-get update && apt-get install -y -f ./bleachbit.deb

apt-get update
apt-get install --no-install-recommends -yqq xfce4-terminal geany qdirstat xfce4-systemload-plugin software-properties-common
apt-get install --no-install-recommends -yqq thunar-archive-plugin gdebi sylpheed
apt-get install -yqq ristretto file-roller
cp -rf defaultapp.conf /etc/xdg/xfce4/helpers.rc
chmod 777 /etc/xdg/xfce4/helpers.rc

# desktop config
mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
cp desktop-config/* /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
mkdir -p /config/.config/xfce4/xfconf/xfce-perchannel-xml/
cp desktop-config/* /config/.config/xfce4/xfconf/xfce-perchannel-xml/
chmod -R 777 /config/.config/

# install firefox
add-apt-repository ppa:mozillateam/ppa -y
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap1-0ubuntu2
Pin-Priority: -1
' | tee /etc/apt/preferences.d/mozilla-firefox

echo 'Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
' | tee /etc/apt/preferences.d/firefox-no-snap
apt-get -qq update && apt-get -qqy --no-install-recommends install firefox fonts-noto-cjk
cp -rf chromium.desktop /usr/share/applications/chromium.desktop
mkdir -p /config
chmod -R 777 /config

# set timezone
apt-get install -yqq --no-install-recommends tzdata
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
echo "Asia/Ho_Chi_Minh" | tee /etc/timezone

apt-get -y autoclean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/
