#!/bin/bash
#
# This script is GB EC2 m3.large Solr Cluster storage configuration
# Ver-0.7 
# Changes: No LVM 
# Date Sep-23-2014

# Check arguments
if [ "$#" -ne 1 ]; then
  echo -e " Usage: $0 <Environment Name>"
  echo -e "   e.g: $0 gbp \n"

  exit 1
fi

ENV=$1

# EBS LVM configuration 
sudo mkfs.ext4 /dev/xvdf
sudo mkdir /ebs
sudo mount /dev/xvdf /ebs -o noatime,nodiratime,data=writeback,nobh

# Configure ephemeral
sudo mkfs.ext4 /dev/xvdb
sudo mkdir /ephemeral
sudo mount /dev/xvdb /ephemeral -o noatime,nodiratime,data=writeback,nobh

# Copy packahges to EBS and Ephemeral
sudo cp -rf /home/gbs/solr/ /ebs/
sudo cp -rf /home/gbs/zookeeper/ /ebs/

# Create tmp directory
sudo mkdir /ephemeral/tmp

# Crerate symlinks
sudo ln -s /ebs/solr/ /home/$ENV/solr
sudo ln -s /ebs/zookeeper/ /home/$ENV/zookeeper
sudo ln -s /ephemeral/tmp/ /home/$ENV/tmp

# Change permissions 
sudo chown -R $ENV:$ENV /home/$ENV/
sudo chown -R $ENV:$ENV /ebs/
sudo chown -R $ENV:$ENV /ephemeral/

