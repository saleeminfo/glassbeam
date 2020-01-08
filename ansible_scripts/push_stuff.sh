#!/bin/bash
#
# Arguments: 
#  1. File name
#  2. Environment name
#  3. Host name
#  4. Target path (optional)
# 

USER=`whoami`
#USER="gbd"
FILE_NAME=$1
ENV_NAME=$2
HOST_NAME=$3
TARGET=$4
HOME_DIR="/ephemeral/work"
EXT_ENV_SSH_PORT=""
INT_ENV_SSH_PORT="22"
PROXY_HOST=""
HDS_PROXY="hds-01"
HDS_TUNNEL_PORT="22222"
HDS_PORT="2022"
HDS_USER="gbh"
PRD_USER="gbp"
DEV_USER="gbd"
QA_USER="gbq"
SU_USER="gbs"


# Check arguments
if [ "$#" -lt 3 ]; then
  echo -e "\nIllegal number of parameters $#"
  echo -e "Usage: $0 file_name environment host_name [target_path]\n"
  exit 1
fi

# Check target location
if [ -z "$4" ]; then
  TARGET=$HOME_DIR
fi 

function scp_direct(){
  echo -e "Trying scp to $ENV_NAME environment $HOST_NAME as $USER user ...\n"
  #echo -e "scp $FILE_NAME $HOST_NAME:$TARGET"
  scp -r $FILE_NAME $HOST_NAME:$TARGET
}

function scp_tunnel(){
  echo -e "Creating SSH Tunnel through $PROXY_HOST as $USER user ...\n"
  eval "ssh -f -N -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oLogLevel=quiet -L $SSH_TUNNEL_PORT:$HOST_NAME:$INT_ENV_SSH_PORT -p $EXT_ENV_SSH_PORT $PROXY_HOST"
  
  sleep 5
  TUNNEL_PID=$(lsof -t -i @localhost:$HDS_TUNNEL_PORT -sTCP:listen)
  echo -e "Tunnel PID: $TUNNEL_PID \n"
   
  echo -e "Pushing file/directory to $HOST_NAME ...\n"
  eval "scp -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oLogLevel=quiet -P $SSH_TUNNEL_PORT -r $FILE_NAME localhost:$TARGET" 

  echo -e "Closing Tunnel ...\n"
  kill -9 $TUNNEL_PID &
   
}

function chek_user(){
# echo -e "check_user:  USER = $USER , SU_USER = $SU_USER , arg1 = $1 "
 if [[ $USER != $SU_USER ]] ; then      
   if [[ $USER != $1 ]] ; then
     echo -e "Incorrect user - '$USER', must be '$1'\n"
     exit 1
   fi
 fi 
 
}


# Check all variables

function check_all(){
echo -e "\nPlease check all parameters:\n"
echo -e "File         - $FILE_NAME"
echo -e "Environment  - $ENV_NAME"
echo -e "Host         - $HOST_NAME"
echo -e "Target Path  - $TARGET"
echo -e "USER         - $USER"
echo -e "Proxy Host   - $PROXY_HOST"
echo -e "SSH T-Port   - $SSH_TUNNEL_PORT"
echo -e "SSH E-Port   - $EXT_ENV_SSH_PORT"
echo -e "SSH I-Port   - $INT_ENV_SSH_PORT"
echo

read -e -p "Are we ready? (Y/n) " -n 1 -r
if [[ $REPLY =~ ^[Nn]$ ]]; then exit ; fi 
echo   

# Chek if file exist
if [[ ! -e $FILE_NAME ]] ; then
  echo -e "File does not exist\n" 
  exit 1
fi  
}


# Check environment/user mapping and process 
case $ENV_NAME in

  hds-*)
   chek_user $HDS_USER
   SSH_TUNNEL_PORT=$HDS_TUNNEL_PORT
   PROXY_HOST=$HDS_PROXY
   EXT_ENV_SSH_PORT=$HDS_PORT 

   check_all
   scp_tunnel
   ;;      

  prod|prd|gbp)
   chek_user $PRD_USER
   check_all
   scp_direct
   ;;

  dev|gbd)
   chek_user $DEV_USER
   check_all
   scp_direct
   ;;

  qa|gbq)
   chek_user $QA_USER
   check_all
   scp_direct
   ;;

  *)
    echo -e "Incorrect Environment \n"
    exit 1
    ;;

esac

