#!/bin/bash

NEW_HOSTNAME=$1

echo "NETWORKING=yes" > /etc/sysconfig/network
echo "HOSTNAME=$NEW_HOSTNAME" >> /etc/sysconfig/network

echo -e "\nInitial Host Name: `hostname`"

hostname $NEW_HOSTNAME
/sbin/service network restart
/sbin/service rsyslog restart

/usr/local/bin/systemstats.sh

echo -e "\nCurrent Host Name: `hostname`"

