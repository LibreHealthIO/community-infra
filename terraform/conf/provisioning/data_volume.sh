#!/bin/bash

set -u
set -e
set -v


mkdir /data

if lsblk | fgrep sdb1; then
 echo "sdb1 already exists, skipping partitioning"
else
  lsblk
  parted /dev/sdb --script -- mklabel gpt
  parted /dev/sdb --script -- mkpart primary 0% 100%
  lsblk
  mkfs.ext4 /dev/sdb1
fi


echo "/dev/sdb1    /data     ext4    defaults    0    0" >> /etc/fstab

mount /data
