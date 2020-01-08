#!/bin/bash
#
# This script is for GB EC2 m3.large 
# Ver-0.7 
# Changes: No LVM 
# Date Feb-11-2015

# Check arguments
if [ "$#" -ne 1 ]; then
  echo -e " Usage: $0 <Environment Name>"
  echo -e "   e.g: $0 gbp \n"

  exit 1
fi

ENV=$1

# Configure ephemeral
sudo mkfs.ext4 /dev/xvdb
sudo mkdir /ephemeral
sudo mount /dev/xvdb /ephemeral -o noatime,nodiratime,data=writeback,nobh

# Create tmp directory
sudo mkdir /ephemeral/tmp

# Crerate symlinks
sudo ln -s /ephemeral/tmp/ /home/$ENV/tmp

# Change permissions 
sudo chown -R $ENV:$ENV /ephemeral/
