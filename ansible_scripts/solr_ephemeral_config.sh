#!/bin/bash
#
# This script is GB Solr Cluster Ephemeral storage configuration
# Ver-0.1
# Date Nov-18-2013
#
#
#

sudo umount -l /media/ephemeral0/
sudo yes|sudo mdadm --create /dev/md1 --level=0 --chunk=4 --raid-devices=2 /dev/xvdb /dev/xvdc
sudo blockdev --setra 65536 /dev/md1
sudo mkfs.ext4 /dev/md1
sudo mkdir /ephemeral
sudo mount /dev/md1 /ephemeral  -o noatime,nodiratime,data=writeback,nobh
sudo chown -R gbp:gbp /ephemeral

