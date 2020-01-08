#!/bin/bash
#
# This script is GB LCP Receiver storage configuration
# Ver-0.1
# Date Nov-13-2013
# 
# check if volumes are attached
sudo pvcreate /dev/sdf
sudo vgcreate rcvr01 /dev/sdf
sudo lvcreate -L249GB -n lv01 rcvr01	# should be variables
sudo mkfs.ext4  /dev/rcvr01/lv01   	# should be variables
sudo mkdir /ebs 
sudo mount /dev/rcvr01/lv01 /ebs -o noatime,nodiratime,data=writeback,nobh
sudo chown -R gbp:gbp /ebs

