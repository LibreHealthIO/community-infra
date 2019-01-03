#!/bin/bash

set -e
set -u
set -x


while [ "$(pgrep 'apt|dpkg')" != "" ];do
  echo "Update still happening..."
  sleep 30
done

dpkg --configure -a
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" --force-yes -y upgrade
reboot -h
