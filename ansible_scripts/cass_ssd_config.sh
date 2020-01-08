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


# Configure ephemeral
sudo mkfs.ext4 /dev/xvdb
sudo mkdir /ephemeral
sudo mount /dev/xvdb /ephemeral -o noatime,nodiratime,data=writeback,nobh

# Configure ephemeral-2
sudo mkfs.ext4 /dev/xvdc
sudo mkdir /ephemeral-2
sudo mount /dev/xvdc /ephemeral-2 -o noatime,nodiratime,data=writeback,nobh

# Copy packahges to ephemeral 
sudo cp -rf /home/gbs/cassandra/ /ephemeral/

# Create tmp directory
sudo mkdir /ephemeral-2/tmp

# Crerate symlinks
sudo rm -f /home/$ENV/tmp
sudo ln -s /ephemeral/cassandra/ /home/$ENV/cassandra
sudo ln -s /ephemeral-2/tmp/ /home/$ENV/tmp

# Change permissions 
sudo chown -R $ENV:$ENV /home/$ENV/
sudo chown -R $ENV:$ENV /ephemeral/
sudo chown -R $ENV:$ENV /ephemeral-2/

