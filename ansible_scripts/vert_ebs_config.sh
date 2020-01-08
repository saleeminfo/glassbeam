#!/bin/bash
#
# This script is GB Solr Cluster EBS storage configuration
# Ver-0.1
# Date Apr-08-2014
# 
# check if volumes are attached
#

sudo yes|sudo mdadm --create /dev/md2 --level=0 --chunk=256 --raid-devices=2 /dev/xvdf /dev/xvdg
sudo pvcreate /dev/md2
sudo vgcreate vert /dev/md2
sudo lvcreate -L499GB -n lv01 vert	# should be variables
sudo mkfs.ext4  /dev/vert/lv01   	# should be variables
sudo mkdir /ebs 
sudo mount /dev/vert/lv01 /ebs -o noatime,nodiratime,data=writeback,nobh
sudo chown -R gbp:gbp /ebs

