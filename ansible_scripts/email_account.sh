#!/bin/bash
#
# This script creates customer email account
# Copyright:    Copyright (c) 2015
# Company:      Glassbeam Inc
# @author       Alexander Mogilevski
# @version      0.2


# Check arguments
if [ "$#" -lt 2 ]; then
  echo -e " Usage: $0 <Customer ID> <Customer Domain Name>"
  echo -e "   e.g: $0 springpath-uat springpath\n"

  exit 1
fi

CUST_ID=$1
DOMAIN_NAME="$2.glassbeam.com" 

BASE="/ebs/mail"
CUST_HOME_DIR="$BASE/$CUST_ID"
PROCMAIL_DIR="$CUST_HOME_DIR/.procmail"
WATCHER_INBOX_DIR="$CUST_HOME_DIR/.inbox"
WATCHER_TMP_DIR="$CUST_HOME_DIR/.wtchr_tmp"
PROCMAIL_SRC="/ebs/watcher/bin/.procmailrc"
PROCMAIL_DEST="$BASE/$CUST_ID/.procmailrc"
COMMENT="Customer_Email_Upload_$DOMAIN_NAME"
LOCAL_HOST_NAMES="/etc/mail/local-host-names"


# Check if user ID exists
getent passwd $CUST_ID > /dev/null
if [ $? -eq 0 ]; then
  tput setaf 1; echo -e "\nPlease choose another Customer ID. The ID $CUST_ID already in use:"
  getent passwd $CUST_ID
  exit 1
else
  tput setaf 3; echo -e "\nCreating $CUST_ID account ..." ; tput sgr 0
  sudo useradd -d $CUST_HOME_DIR -c $COMMENT $CUST_ID
  id $CUST_ID
  grep "^$CUST_ID" /etc/passwd
fi

# Create directori structure
sudo mkdir -p $PROCMAIL_DIR $WATCHER_INBOX_DIR $WATCHER_TMP_DIR
sudo cp $PROCMAIL_SRC $PROCMAIL_DEST
sudo chown -R $CUST_ID:$CUST_ID $CUST_HOME_DIR
sudo /bin/sh -c "rm -f $CUST_HOME_DIR/.bash*" 

tput setaf 3; echo -e "\nFollowing directory structure is created:"; tput sgr 0
sudo ls -la $BASE/$CUST_ID

# Updating local-host-names
if grep -Fxq "$DOMAIN_NAME" $LOCAL_HOST_NAMES ; then
  tput setaf 3; echo -e "\nDomain Name: $DOMAIN_NAME already exists, skipping ..."; tput sgr 0
  cat $LOCAL_HOST_NAMES
else 
  sudo /bin/sh -c "echo $DOMAIN_NAME >> $LOCAL_HOST_NAMES"
  tput setaf 3; echo -e "\nUpdated /etc/mail/local-host-names:"; tput sgr 0
  cat $LOCAL_HOST_NAMES
fi

# Restart sendmail service
tput setaf 3; echo -e "\nRestarting Sendmail Service ..."; tput sgr 0
sudo service sendmail restart

if [ $? -eq 0 ]; then
  tput setaf 2; echo -e "\nDone!"; tput sgr 0

fi




