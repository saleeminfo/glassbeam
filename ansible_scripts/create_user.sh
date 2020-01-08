#!/bin/bash
#

USER_NAME=$1
USER_GROUP=$2
USER_EMAIL=$3
PUB_KEY_FILE=$4

useradd -G $USER_GROUP -d /home/$USER_NAME -c "$USER_EMAIL" $USER_NAME

mkdir /home/$USER_NAME/.ssh
cp $PUB_KEY_FILE /home/$USER_NAME/.ssh/authorized_keys
chmod 0700 /home/$USER_NAME/.ssh/
chmod 0600 /home/$USER_NAME/.ssh/authorized_keys
chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/

