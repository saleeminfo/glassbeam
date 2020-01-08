#!/bin/bash
#
# Ver-0.1
# Date Nov-13-2013
# 
# check if volumes are attached
sudo pvcreate /dev/xvdf
sudo vgcreate rdbm01 /dev/xvdf
sudo lvcreate -L249GB -n lv01 rdbm01	# should be variables
sudo mkfs.ext4  /dev/rdbm01/lv01   	# should be variables
sudo mkdir /ebs 
sudo mount /dev/rdbm01/lv01 /ebs -o noatime,nodiratime,data=writeback,nobh
sudo chown -R gbp:gbp /ebs

