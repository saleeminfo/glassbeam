#!/bin/bash
#
# This script creates SFTP chroot account
# Copyright:    Copyright (c) 2015
# Company:      Glassbeam Inc
# @author       Alexander Mogilevski
# @version      0.2


# Check arguments
if [ "$#" -lt 1 ]; then
  echo -e " Usage: $0 <Customer ID>"
  echo -e "   e.g: $0 vmem_pod\n"

  exit 1
fi

CUST_ID=$1
SFTP_GROUP="sftpusers"
BASE="/ebs/sftp"
DIR="/.inbox"
COMMENT="Customer_sftp_"
WATCHER_TMP_DIR="/.wtchr_tmp"
SFTP_KEY="/etc/ssh/ssh-pool/$CUST_ID.pub"

# Check if SFTP group exists
getent group $SFTP_GROUP > /dev/null 
if [ $? -ne 0 ]; then
  echo -e "\nCreating $SFTP_GROUP group..."
  sudo groupadd $SFTP_GROUP
  getent group $SFTP_GROUP
else
  echo -e "\nGroup $SFTP_GROUP exists"
  getent group $SFTP_GROUP
fi


# Check if user ID exists
getent passwd $CUST_ID > /dev/null
if [ $? -eq 0 ]; then
  echo -e "\nPlease choose another Customer ID. The ID $CUST_ID already in use:"
  getent passwd $CUST_ID
  exit 1
else
  echo -e "\nCreating $CUST_ID user ID..."  
  sudo useradd -g $SFTP_GROUP -d "$DIR" -c $COMMENT -s /sbin/nologin $CUST_ID
  id $CUST_ID
  grep $CUST_ID /etc/passwd
fi

# Create customer chroot directory structure
sudo mkdir -p $BASE/$CUST_ID$WATCHER_TMP_DIR -m 700
sudo mv $DIR $BASE/$CUST_ID/

# Change permissions 
sudo chmod 755 $BASE/$CUST_ID$DIR

# Remove bash files
sudo rm -rf $BASE/$CUST_ID$DIR/.bash*

echo -e "\nFollowing directory structure is created:"
ls -la $BASE/$CUST_ID

# Place customer public key
echo -e "\n"
read -p "Please copy and paste customer public key: " -e public_key

echo $public_key | sudo tee $SFTP_KEY >> /dev/null

echo -e "\nSSH key has been placed in $SFTP_KEY as follow:"
echo `cat $SFTP_KEY`
