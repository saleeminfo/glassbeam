#!/bin/bash

# This script is pushing Cassandra artifacts
# Ver-0.1
# Date Feb-11-2015

# Check arguments
if [ "$#" -ne 3 ]; then
  echo -e " Usage: $0 <Environment Name> <hostname> <version>"
  echo -e "   e.g: $0 gbd gbd-cass-15 2.1.3\n"

  exit 1
fi

ENV=$1
HOST=$2
VER=$3


ansible $HOST -m shell -a "mkdir /ebs/cassandra/ && ln -s /ebs/cassandra" -U $ENV --sudo 

wait
ansible $HOST -m copy -a "src=~/repos/cassandra/apache-cassandra-$VER-bin.tar.gz dest=/home/$ENV/cassandra/" -U $ENV --sudo

wait
ansible $HOST -m shell -a "cd /home/$ENV/cassandra/ && tar xfz apache-cassandra-$VER-bin.tar.gz && ln -s apache-cassandra-$VER/ current" -U $ENV --sudo

wait
ansible $HOST -m copy -a "src=/ebs/gbs/deploy/base/$ENV/apps/cassandra/$VER/conf dest=~/cassandra/current/" -U $ENV --sudo

