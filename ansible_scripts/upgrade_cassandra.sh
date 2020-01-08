#!/bin/bash
# 
# Arguments: 
# 1 - Cassandra version, i.e:  
#   $upgrade_cassandra.sh 2.0.5
#
# ! Based on:
#    -  Apache Cassandra repo name stucture, must be like: 
#       apache-cassandra-x.x.x-bin.tar.gz 
#
#    -  Ansible host definition    - /etc/ansible/hosts
#  
# ! C* home directory symlinks must be present as follow: 
#    - for DR node      ~/cassandra -> /ebs/casssandra
#    - for Ephemrarals  ~/cassandra -> /ephemeral/cassandra
# 

# Environment definition
SYS_USER="gbp"

# C* version
C_CURRENT="cassandra-2.0.2"
C_LATEST="cassandra-$1"
C_TARBALL="apache-cassandra-$1-bin.tar.gz"

# Repo and Artefacts location
REPO_HOME="https://s3.amazonaws.com/gb-s3-repo/cassandra"
DEPLOY_REPO_HOME="/home/$SYS_USER/deploy/repo"

# Groups in C* cluster
C_GROUP="cassandra"
C_HOME="/home/$SYS_USER/cassandra"

# Check arguments
if [ "$#" -ne 1 ]; then
  echo -e "Illegal number of parameters $#\n"
  exit 1
fi

# Check all variables
echo -e "Please check all parameters:\n"
echo -e "Current version - $C_CURRENT"
echo -e "Upgrading to    - $C_LATEST"
echo -e "Tarball         - $C_TARBALL"
echo -e "Repo home       - $REPO_HOME"
echo -e "Deployment home - $DEPLOY_REPO_HOME"
echo -e "Target          - $C_HOME"
echo
read -p "Are we ready? (y/N) " -n 1 -r
echo   

# Ask first!
if [[ $REPLY =~ ^[Yy]$ ]]; then 

# Create list of C* nodes
#ansible $C_GROUP -m shell -a "hostname" | grep $SYS_USER > $C_NODE_LIST

# Download tarball from repository
wget --no-check-certificate $REPO_HOME/$C_TARBALL -P $DEPLOY_REPO_HOME   
echo -e "Download completed\n"

# Check if file is downloded 
if [ -f $DEPLOY_REPO_HOME/$C_TARBALL ]; then
  echo -e "Tarball deployed\n"
else 
  exit 1    
fi

# Push tar archive to all C* nodes 
ansible $C_GROUP -m copy -a "src=$DEPLOY_REPO_HOME/$C_TARBALL dest=$C_HOME" --sudo

# Unpack and remove tar file
ansible $C_GROUP -m shell -a "cd $C_HOME && tar xfz $C_HOME/$C_TARBALL && rm -f $C_HOME/$C_TARBALL" --sudo
echo -e "Done unpacking\n"

# Create new link to lib and log location
ansible $C_GROUP -m shell -a "cd /var/lib/ && ln -s $C_HOME  $C_LATEST" --sudo
echo -e "/var/lib/ link is created\n"

# Copy /conf from current running instance
ansible $C_GROUP -m shell -a "cp -rf $C_HOME/apache-$C_CURRENT/conf $C_HOME/apache-$C_LATEST/" --sudo
echo -e "/conf folder is replaced\n"

# Change 'current' version
ansible cassandra -m shell -a "cd $C_HOME && rm -rf current && ln -s apache-$C_LATEST current" --sudo
echo -e "Current version is changed\n"

# Change ownership on new C* directory
ansible $C_GROUP -m shell -a "chown -R $SYS_USER:$SYS_USER $C_HOME/apache-$C_LATEST current"  --sudo 
echo -e "Owner changed to $SYS_USER\n"

echo -e "We are done! \n"

else
  exit 1 
fi

