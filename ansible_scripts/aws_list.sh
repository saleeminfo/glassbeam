#!/bin/bash
# This script creates a list of host - IP records
# Copyright:    Copyright (c) 2015
# Company:      Glassbeam Inc
# @author       Alexander Mogilevski
# @version      0.2
# 
# Requiered aws-cli Version 1.7.29 or higher 
# Run 'aws --version' to find it out

# Check arguments
if [ "$#" -lt 1 ]; then
  echo -e " Usage: $0 <Hostname Pattern> <table>"
  echo -e "   e.g: $0 gbp-cass-* table\n"

  exit 1
fi

PATTERN=$1
OUTPUT=$2

if [[ $OUTPUT == "table" ]]; then 
  echo ""
  aws ec2 describe-instances --filters "Name=tag-value,Values=$PATTERN"  --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0], NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress]' --output $OUTPUT | sort -g

else
  echo ""
  aws ec2 describe-instances --filters "Name=tag-value,Values=$PATTERN"  --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0], NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress]' --output text | sort -g

fi 
