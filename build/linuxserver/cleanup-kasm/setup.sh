#!/bin/bash
set -eux
export DEBIAN_FRONTEND="noninteractive"
trap 'sudo rm -rf /workspace/**' EXIT

dpkg-divert --divert /etc/PackageKit/20packagekit.distrib --rename /etc/apt/apt.conf.d/20packagekit

apt-get -y autoclean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/
