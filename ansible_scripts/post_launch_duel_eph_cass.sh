#!/bin/bash

# Post installation script
# Ver-0.3
# Date 2015/12/08

# Check arguments
if [ "$#" -ne 5 ]; then
  echo -e " Usage: $0 <Environment Name> <hostname> <C* Custer Name> <C* Seed #1> <C* Seed #2>"
  echo -e "   e.g: $0 gbp gbd-cass-11 gbp-11 gbp-cass-11 gbp-cass-12\n"

  exit 1
fi

ENV=$1
HOST=$2
CASS_CLUSTER_NAME=$3
CASS_SEED_1=$4
CASS_SEED_2=$5

echo -e "\nDeploying MOTD ..."
ansible $HOST -m copy -a "src=~/deploy/base/$ENV/systemstats.sh dest=/usr/local/bin/ mode=0755" -s

wait
echo -e "\nDeploying HostName change script ..."
ansible $HOST -m copy -a "src=~/deploy/bin/cass_hostname.sh dest=~/bin/ mode=0755"

wait
ansible $HOST -m shell -a "/home/gbs/bin/cass_hostname.sh $HOST $CASS_CLUSTER_NAME $CASS_SEED_1 $CASS_SEED_2" -s

wait
echo -e "\nDeploying File System configuration script ..."
ansible $HOST -m copy -a "src=~/bin/eph-2x800-raid-0_config.sh dest=~/bin/ mode=0755"

wait
echo -e "\nConfiguring File System(s), please wait ..."
ansible $HOST -m shell -a "~/bin/eph-2x800-raid-0_config.sh $ENV"

echo -e "\nDeploying /etc/fstab ..."
ansible $HOST -m copy -a "src=~/deploy/base/wide/system/etc/eph_raid-0_fstab dest=/etc/fstab mode=0644" -s

wait
echo -e "\nDeploying GitHub key ..."
ansible $HOST -m copy -a "src=~/deploy/base/secret/git/id_rsa dest=~/.ssh/ mode=0600" -U $ENV -s

wait
echo -e "\nDeploying cass_conf.sh ..."
ansible $HOST -m copy -a "src=~/deploy/bin/cass_config.sh dest=~/ mode=755" -U $ENV -s

echo -e "\nRemoving artifacs ..."
ansible $HOST -m shell -a "rm -r ~/bin/cass_hostname.sh"
ansible $HOST -m shell -a "rm -r ~/bin/eph-2x800-raid-0_config.sh"

echo -e "\nDone!"
