#!/bin/bash
# This script installs cassandra on the local machine. The cassandra version must be specified as the first argument to this program.
# Run this script from the directory under which the cassandra directory will be created
# set -x #echo on

if [ $# != 2 ]; then
  echo "Usage: $0 cassandra-version seed-ip-address"
  exit
else
 VERSION="$1"
 SEED_IP="$2"
fi

# Eventually the variables defined here should come from command line parameters. For now just update them manually.
DC='east'
RAC='RAC1'
SEED_NODES='- seeds: ''"'$SEED_IP'"'

# all the stuff down from here should not require any manual changes.
PKGS=pkgs
BASE_DIR=apache-cassandra-$VERSION
CONF_DIR=$BASE_DIR/conf
YAML_ORIG=$CONF_DIR/cassandra.yaml.orig
RACKDC_ORIG=$CONF_DIR/cassandra-rackdc.properties.orig
YAML_FILE=$CONF_DIR/cassandra.yaml
RACKDC_FILE=$CONF_DIR/cassandra-rackdc.properties
CLUSTER_NAME='cluster_name:'
SEEDS_ORIG='- seeds: "127.0.0.1"'
SNITCH='endpoint_snitch:'
GPF_SNITCH=GossipingPropertyFileSnitch
RPC_ADD='rpc_address:'
LISTEN_ADD='listen_address:'
MY_IP=`hostname -i`

if [ ! -d "$PKGS" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
  mkdir $PKGS
fi

cd pkgs
if [ "$VERSION" == 2.1.1 ]
then
  curl -OL http://apache.claz.org/cassandra/$VERSION/apache-cassandra-$VERSION-bin.tar.gz
else
  curl -OL http://archive.apache.org/dist/cassandra/$VERSION/apache-cassandra-$VERSION-bin.tar.gz
fi
cd ..

tar -zxf pkgs/apache-cassandra-$VERSION-bin.tar.gz

mv $YAML_FILE $YAML_ORIG
mv $RACKDC_FILE $RACKDC_ORIG

sed -e "/$CLUSTER_NAME/ c $CLUSTER_NAME 'Glassbeam Cluster'" -e "s/$SEEDS_ORIG/$SEED_NODES/" -e "
/$SNITCH/ c $SNITCH $GPF_SNITCH"  -e "/$RPC_ADD/ c $RPC_ADD $MY_IP" -e "/$LISTEN_ADD/ c $LISTEN_ADD $MY_IP"  <$YAML_ORIG >$YAML_FILE

cat >$RACKDC_FILE <<EOL
dc=$DC
rack=$RAC
EOL

