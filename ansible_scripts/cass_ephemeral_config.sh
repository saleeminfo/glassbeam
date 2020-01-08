#!/bin/bash
#
# This script is GB Cassandra Cluster Ephemeral storage RAID0 
# Ver-0.2
# Date Jan-26-2015
#
#

# Check arguments
if [ "$#" -ne 1 ]; then
  echo -e " Usage: $0 <Environment Name>"
  echo -e "   e.g: $0 gbp \n"

  exit 1
fi

ENV=$1

sudo yes|sudo mdadm --create /dev/md1 --level=0 --chunk=4 --raid-devices=2 /dev/xvdb /dev/xvdc
sudo blockdev --setra 65536 /dev/md1
sudo mkfs.ext4 /dev/md1
sudo mkdir /ephemeral
sudo mount /dev/md1 /ephemeral -o noatime,nodiratime,data=writeback,nobh
sudo chown -R $ENV:$ENV /ephemeral

