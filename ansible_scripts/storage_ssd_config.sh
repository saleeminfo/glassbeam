#!/bin/bash
#
# Ver-0.1
# Date Aug-11-2014
#
#
sudo mkfs.ext4 /dev/xvdb
sudo mkdir /ephemeral
sudo mount /dev/xvdb /ephemeral -o noatime,nodiratime,data=writeback,nobh
sudo chown -R gbp:gbp /ephemeral
sudo echo '/dev/xvdb  /ephemeral  ext4 noatime,nodiratime,data=writeback,nobh 0 0' >> /etc/fstab
