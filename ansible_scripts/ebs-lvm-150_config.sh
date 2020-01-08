#!/bin/bash
#
# This script is GB EC2 m3.large storage configuration with 250GB EBS volume 
# Ver-0.5
# Date Mar-05-2015

# Check arguments
if [ "$#" -ne 1 ]; then
  echo -e " Usage: $0 <Environment Name>"
  echo -e "   e.g: $0 gbp \n"

  exit 1
fi

ENV=$1

echo -e "\nInitial File Systems:"
df -h

sudo pvcreate /dev/xvdf
sudo vgcreate ebs /dev/xvdf
sudo lvcreate -L149GB -n lv01 ebs

echo -e "\nCreating ext4 File System, please wait ..."
sudo mkfs.ext4 /dev/ebs/lv01

wait
echo -e "\nMounting volume ..."
sudo mkdir /ebs
sudo mount /dev/ebs/lv01 /ebs -o noatime,nodiratime,data=writeback,nobh
sudo mkdir /ebs/tmp

sudo chown -R $ENV:$ENV /ebs/

echo -e "\nCurrent File Systems:"
df -h
