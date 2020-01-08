#!/bin/bash
#
# This script is GB Cassandra Cluster Ephemeral 2x800 RAID-0 configuration for i2.2xlarge instance
# Ver-0.2
# Date 2015/12/08
#
#

# Check arguments
if [ "$#" -ne 1 ]; then
  echo -e " Usage: $0 <Environment Name>"
  echo -e "   e.g: $0 gbp \n"

  exit 1
fi

ENV=$1

echo -e "\nCreating RAID-0 for /dev/xvdb /dev/xvdc ..."
sudo yes|sudo mdadm --create /dev/md2 --chunk=256 --metadata=1.2 --raid-devices=2 --level=0 /dev/xvdb /dev/xvdc


echo -e "\nCreating ext4 File System, please wait ..."
sudo mkfs.ext4 /dev/md2

wait
echo -e "\nMounting to /ephemeral ..."
sudo mkdir /ephemeral
sudo mount /dev/md2 /ephemeral/ -o noatime,nodiratime,data=writeback,nobh

wait
sudo chown -R $ENV:$ENV /ephemeral

echo -e "\nCurrent File Systems:"
df -h
