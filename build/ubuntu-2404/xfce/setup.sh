#!/bin/bash

set -eux
export DEBIAN_FRONTEND=noninteractive
trap 'sudo rm -rf /workspace/**' EXIT
if [[ $EUID -ne 0 ]]; then
   exec sudo -E /bin/bash "$0" "$@"
fi

# install xfce4
apt-get update
apt-get install --no-install-recommends -yqq apt-utils curl software-properties-common netcat-openbsd
apt-get install --no-install-recommends -yqq xfce4 tigervnc-standalone-server dbus-x11 git python3-numpy

# install npm
# apt-get install --no-install-recommends -yqq npm
# npm install -g npm@9.2.0
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - 
apt-get install -y nodejs

# gui app
apt-get install --no-install-recommends -yqq xfce4-terminal geany qdirstat xfce4-systemload-plugin
apt-get install --no-install-recommends -yqq thunar-archive-plugin gdebi sylpheed
apt-get install -yqq ristretto file-roller

git clone https://github.com/novnc/noVNC /opt/noVNC
rm -rf /opt/noVNC/.github
rm -rf /opt/noVNC/.git
git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify
rm -rf /opt/noVNC/utils/websockify/.github
rm -rf /opt/noVNC/utils/websockify/.git

sed -i 's/window.location.hostname/window.location.host + window.location.pathname/g' /opt/noVNC/app/ui.js
sed -i "s/UI\.initSetting('resize', 'off');/UI.initSetting('resize', 'remote');/g" /opt/noVNC/app/ui.js
cp /opt/noVNC/vnc.html /opt/noVNC/index.html
npm install --prefix /opt/noVNC --no-audit --no-fund --legacy-peer-deps ws

# start script
cp -rf scripts/* /usr/local/bin/
chmod -R 777 /usr/local/bin/

# disable logout
rm -rf /usr/bin/xflock4
rm -rf /usr/sbin/shutdown /usr/sbin/reboot /usr/sbin/halt /usr/sbin/poweroff

# set timezone
apt-get install -yqq --no-install-recommends tzdata
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
echo "Asia/Ho_Chi_Minh" | tee /etc/timezone

# desktop config
mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
cp desktop-config/* /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/

# default app
cp -rf defaultapp.conf /etc/xdg/xfce4/helpers.rc
chmod 777 /etc/xdg/xfce4/helpers.rc

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

echo "cleanup"
if [[ $EUID -ne 0 ]]; then
   exec sudo -E /bin/bash "$0" "$@"
fi
if [ -x "$(command -v npm)" ]; then
   npm cache clean --force 2>&1
   rm -rf "${HOME}"/.npm/* "${HOME}"/.node-gyp/*
fi
apt-get -y autoclean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/ /workspace/*
