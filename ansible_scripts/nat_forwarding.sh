#!/bin/bash
# This script is GB bst-01 NAT forwarding configuration 
# Ver-0.1
# Date Mar-10-2015

# Check arguments
if [ "$#" -ne 3 ]; then
  echo -e " Usage: $0 <Forwarding port> <Hostname> <Target Port>"
  echo -e "   e.g: $0 8888 gbp-cass-dr 80 \n"
  exit 1
fi

NATF_HOST="bst-01"

if [ `hostname` != $NATF_HOST ]; then
  echo -e " It Should be running on: $NATF_HOST"
  exit 1
fi

BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' 

FRWD_PORT=$1
HOSTNAME=$2
IP=`grep $HOSTNAME /etc/hosts | awk '{print $1}'`
TARGET_PORT=$3

# Prerouting 
echo sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $FRWD_PORT \
 -j DNAT --to $IP:$TARGET_PORT 
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $FRWD_PORT \
 -j DNAT --to $IP:$TARGET_PORT 

# Accept forwarding
echo sudo iptables -A FORWARD -i eth0 -p tcp --dport $TARGET_PORT -d $IP -j ACCEPT
sudo iptables -A FORWARD -i eth0 -p tcp --dport $TARGET_PORT -d $IP -j ACCEPT

# Postrouting
echo sudo iptables -t nat -A POSTROUTING -p tcp --dport $TARGET_PORT -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -p tcp --dport $TARGET_PORT -j MASQUERADE

# Save and restart
echo sudo /etc/init.d/iptables save 
echo sudo /etc/init.d/iptables restart
sudo /etc/init.d/iptables save 
sudo /etc/init.d/iptables restart

# Reset counters
echo sudo iptables -t nat -Z
sudo iptables -t nat -Z

# Check  
echo -e "\n\n${BLUE}cat /etc/sysconfig/iptables${NC} \n"
sudo cat /etc/sysconfig/iptables

#echo -e "\n\n${BLUE}iptables -t nat -L -v -n ${NC} \n"
#sudo iptables -t nat -L -v -n 

echo -e "\n\n${BLUE}nc -v $IP $TARGET_PORT${NC} \n"
nc -v $IP $TARGET_PORT





