#!/bin/bash

# Post installation script
# Ver-0.2
# Date June-19-2015

# Check arguments
if [ "$#" -ne 2 ]; then
  echo -e " Usage: $0 <Environment Name> <hostname>"
  echo -e "   e.g: $0 gbd gbd-cass-15\n"

  exit 1
fi

ENV=$1
HOST=$2

echo -e "\nDeploying MOTD..."
ansible $HOST -m copy -a "src=~/deploy/base/$ENV/systemstats.sh dest=/usr/local/bin/ mode=0755" -s

# TODO: need loop for host list here
wait
echo -e "\nDeploying HostName change script ..."
ansible $HOST -m copy -a "src=~/bin/hostname_change.sh dest=~/bin/ mode=0755"

wait
ansible $HOST -m shell -a "/home/gbs/bin/hostname_change.sh $HOST" -s

wait
echo -e "\nDeploying File System configuration script ..."
ansible $HOST -m copy -a "src=~/bin/ebs-lvm-200_config.sh dest=~/bin/ mode=0755"

wait
echo -e "\nConfiguring File System(s), please wait ..."
ansible $HOST -m shell -a "~/bin/ebs-lvm-200_config.sh $ENV"

echo -e "\nDeploying /etc/fstab ..."
ansible $HOST -m copy -a "src=~/deploy/base/wide/system/etc/eph_ebs_lvm_fstab dest=/etc/fstab mode=0644" -s

wait
echo -e "\nDeploying GitHub key ..."
ansible $HOST -m copy -a "src=~/deploy/base/secret/git/id_rsa dest=~/.ssh/ mode=0600" -U $ENV -s

echo -e "\nRemoving artifacs ..."
ansible $HOST -m shell -a "rm -r ~/bin/hostname_change.sh"
ansible $HOST -m shell -a "rm -r ~/bin/ebs-lvm-200_config.sh"

echo -e "\nDone!"
