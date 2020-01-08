#!/bin/bash
#
#
SOURCE_DIR=$1
TARGET_DIR=$1
TARGET_HOST=$2

# Check arguments
if [ "$#" -ne 2 ]; then
  echo -e "\n Usage: $0 dir_path host_name \n"
  exit 1
fi

rsync -avzhe ssh $SOURCE_DIR $TARGET_HOST:$TARGET_DIR

