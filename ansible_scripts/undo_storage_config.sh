#!/bin/bash
#
# This script is UNDO GB EC2 m3.large Solr Cluster storage configuration
# Ver-0.7
# Changes: No LVM
# Date Sep-25-2014
#
# Check arguments
if [ "$#" -ne 1 ]; then
  echo -e " Usage: $0 <Environment Name>"
  echo -e "   e.g: $0 gbp \n"

  exit 1
fi

ENV=$1

read -e -p "!!! We are about to wipe off all attached storage!!! Are we ready? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo rm -rf /ephemeral/tmp
  sudo umount -f /ebs
  sudo umount -f /ephemeral
  sudo rm -rf /ebs
  sudo rm -rf /ephemeral
  sudo rm -f /home/$ENV/solr /home/$ENV/zookeeper /home/$ENV/tmp /home/$ENV/cassandra
else
  exit 1
fi

# Check File Systems 
echo -e "\n"
df -h


