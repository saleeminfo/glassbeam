#!/bin/bash
#
# This script is GB Cassandra Cluster EBS storage configuration
# Ver-0.1
# Date Sep-03-2014
# 
# check if volumes are attached
sudo pvcreate /dev/sdf
sudo vgcreate ebs /dev/sdf
sudo lvcreate -L249GB -n lv01 ebs
sudo mkfs.ext4  /dev/ebs/lv01   
sudo mkdir /ebs 
sudo mount /dev/ebs/lv01 /ebs -o noatime,nodiratime,data=writeback,nobh
sudo chown -R gbp:gbp /ebs

