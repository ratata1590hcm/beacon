#!/bin/bash
set -eux
export DEBIAN_FRONTEND="noninteractive"
trap 'sudo rm -rf /workspace/**' EXIT

echo "install code-server"
curl -fsSL https://code-server.dev/install.sh | sh

echo "install extension"
PATH="$HOME/.local/bin:$PATH"
code-server --install-extension ms-azuretools.vscode-containers
# code-server --install-extension docker.docker
code-server --install-extension njzy.stats-bar
git config --global http.sslVerify false
git config --global credential.helper store

echo "code-server config"
mkdir -p ~/.config/code-server/
cp -f config/code-server-setting.yaml ~/.config/code-server/config.yaml
sudo chmod 444 ~/.config/code-server/config.yaml

echo "User settings"
mkdir -p ~/.local/share/code-server/User/
cp -f config/User/settings.json ~/.local/share/code-server/User/settings.json
sudo chmod 777 ~/.local/share/code-server/User/settings.json

# support openshift
sudo mkdir -p /.config/code-server/
sudo chmod -R 777 /.config
cp -f config/code-server-setting.yaml /.config/code-server/config.yaml
sudo chmod -R 777 /.config
sudo mkdir -p /.local/share/code-server/User/
sudo chmod -R 777 /.local
cp -f config/User/settings.json /.local/share/code-server/User/settings.json
sudo chmod -R 777 /.local

echo "patch dpkg to not install when exist"
if [ ! -f /bin/dpkg.real ]; then
    echo "Creating backup and installing wrapper in /bin ..."
    sudo mv /bin/dpkg /bin/dpkg.real
    sudo cp dpkg-patch/dpkg.sh /bin/dpkg
    sudo chmod 755 /bin/dpkg
else
    echo "dpkg.real already exists in /bin → skipping to protect the backup"
fi

echo "cleanup"
if [[ $EUID -ne 0 ]]; then
   exec sudo -E /bin/bash "$0" "$@"
fi
apt-get -y autoclean
apt-get -y autoremove
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/ /workspace/*
