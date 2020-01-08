#!/bin/bash
#
# This script is GB Cassandra Cluster EBS storage configuration
# Ver-0.1
# Date Nov-13-2013
# 
# check if volumes are attached
sudo yes|sudo mdadm --create /dev/md2 --level=0 --chunk=4 --raid-devices=2 /dev/xvdf /dev/xvdg
sudo pvcreate /dev/md2
sudo vgcreate dr01 /dev/md2
sudo lvcreate -L999GB -n lv01 dr01	# should be variables
sudo mkfs.ext4  /dev/dr01/lv01   	# should be variables
sudo mkdir /ebs 
sudo mount /dev/dr01/lv01 /ebs -o noatime,nodiratime,data=writeback,nobh
sudo chown -R gbp:gbp /ebs

