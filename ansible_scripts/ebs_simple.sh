#!/bin/bash
#
# This script is GB EC2 m3.large
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

# EBS configuration 
sudo mkfs.ext4 /dev/xvdf
sudo mkdir /ebs 
sudo mount /dev/xvdf /ebs -o noatime,nodiratime,data=writeback,nobh

# Change permissions 
sudo chown -R $ENV:$ENV /ebs/
