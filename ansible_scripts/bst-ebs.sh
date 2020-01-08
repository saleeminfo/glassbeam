#!/bin/bash
#
# The script is used to create and mount EBS LVM volume to bst host
# Prerequisites: attached /dev/xvdm volume 
#

vgcreate bst /dev/xvdm
lvcreate -L99GB -n ebs01 bst
mkfs.ext4 /dev/bst/ebs01
mount /dev/bst/ebs01 /ebs 
chown -R gbs:gbs /ebs
mkdir /ebs/gbp
chown -R gbp:gbp /ebs/gbp

