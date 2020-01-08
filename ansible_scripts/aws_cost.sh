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
  echo -e " Usage: $0 <Environment Pattern> <Instance Type Pattern>"
  echo -e "   e.g: $0 gbp* m1*\n"

  exit 1
fi

PATTERN=$1
INST_TYPE=$2

if [[ $INST_TYPE ]]; then
  echo ""
  aws ec2 describe-instances --filters "Name=tag-value,Values=$PATTERN" "Name=instance-type,Values=$INST_TYPE" --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0], InstanceType]' --output text | wc -l

else
  echo ""
  aws ec2 describe-instances --filters "Name=tag-value,Values=$PATTERN" --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0], InstanceType]' --output text | wc -l


fi
