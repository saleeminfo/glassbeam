#!/bin/bash
#
# This script is GB Cassandra Cluster Ephemeral 
# Ver-0.1
# Date 2015/06/17
#
#

# Check arguments
if [ "$#" -ne 1 ]; then
  echo -e " Usage: $0 <Environment Name>"
  echo -e "   e.g: $0 gbp \n"

  exit 1
fi

ENV=$1

echo -e "\nInitial File Systems:"
df -h

sudo pvcreate /dev/xvdb
sudo vgcreate eph /dev/xvdb

# for volume 800GB use -L745GB 
sudo lvcreate -L745GB -n lv01 eph

echo -e "\nCreating ext4 File System, please wait ..."
sudo mkfs.ext4 /dev/eph/lv01

wait
echo -e "\nMounting first volumei ..."
sudo mkdir /ephemeral
sudo mount /dev/eph/lv01 /ephemeral/ -o noatime,nodiratime,data=writeback,nobh

wait
echo -e "\nExtending first volume ..."
sudo pvcreate /dev/xvdc
sudo vgextend eph /dev/xvdc

wait
sudo lvextend /dev/eph/lv01 /dev/xvdc

wait
echo -e "\nResizing first logical volume ..."
sudo resize2fs /dev/eph/lv01

wait
sudo chown -R $ENV:$ENV /ephemeral

echo -e "\nCurrent File Systems:"
df -h
