#/bin/bash 
#
# This script is simple disk performance test 
# Ver-0.2
# Date Apr-09-2015

# Check arguments
if [ "$#" -ne 4 ]; then
  echo -e " Usage: $0 <Volume> <Bloc Size> <Number of blocks> <Sleep Teme Sec>"
  echo -e "   e.g: $0 ebs 1MB 1024 60\n"

  exit 1
fi

VOLUME=$1
BLOCK_SIZE=$2
COUNT=$3
SLEEP_TIME=$4
FILE_NAME="$COUNT""_dump_file"
DIR_NAME="perf_test"
DIR_PATH="/$VOLUME/$DIR_NAME"

if [ ! -d $DIR_PATH ]; then
  mkdir $DIR_PATH
fi
cd $DIR_PATH

#if [ $? -ne 0 ]; then
#  echo -e "\n\e[0;31m$DIR_PATH doesn't exist\e[0m"
#  exit 1
#fi

echo -e "\n\e[1;33m1. Most optimistic - sync at the end" 
echo -e "Started at `date +%H:%M:%S`\e[0m"  
echo dd bs=$BLOCK_SIZE count=$COUNT if=/dev/zero of=$FILE_NAME conv=fdatasync
dd bs=$BLOCK_SIZE count=$COUNT if=/dev/zero of=$FILE_NAME conv=fdatasync
echo -e "\e[1;33mFinished at `date +%H:%M:%S`\e[0m"

wait
rm -f $FILE_NAME

echo -e "\n\e[1;32mSleeping for $SLEEP_TIME seconds...\e[0m"  
sleep $SLEEP_TIME


echo -e "\n\e[1;33m2. Most conscious - sync after every block"
echo -e "Started at `date +%H:%M:%S`\e[0m"  
echo dd bs=$BLOCK_SIZE count=$COUNT if=/dev/zero of=$FILE_NAME oflag=dsync
dd bs=$BLOCK_SIZE count=$COUNT if=/dev/zero of=$FILE_NAME oflag=dsync
echo -e "\e[1;33mFinished at `date +%H:%M:%S`\e[0m"

wait
rm -f $FILE_NAME

echo -e "\n\e[1;32mSleeping for $SLEEP_TIME seconds...\e[0m"  
sleep $SLEEP_TIME

echo -e "\n\e[1;33m3. Most difficult - random input" 
echo -e "Started at `date +%H:%M:%S`\e[0m"  
echo dd bs=$BLOCK_SIZE count=$COUNT if=/dev/urandom of=$FILE_NAME oflag=dsync 
dd bs=$BLOCK_SIZE count=$COUNT if=/dev/urandom of=$FILE_NAME conv=fdatasync 
echo -e "\e[1;33mFinished at `date +%H:%M:%S`\e[0m"

wait
rm -f $FILE_NAME

echo -e "\n\e[1;32mSleeping for $SLEEP_TIME seconds...\e[0m"  
sleep $SLEEP_TIME

echo -e "\n\e[1;33m4. Most pessimistic - random input and sync after every block" 
echo -e "Started at `date +%H:%M:%S`\e[0m"  
echo dd bs=$BLOCK_SIZE count=$COUNT if=/dev/urandom of=$FILE_NAME oflag=dsync 
dd bs=$BLOCK_SIZE count=$COUNT if=/dev/urandom of=$FILE_NAME oflag=dsync 
echo -e "\e[1;33mFinished at `date +%H:%M:%S`\e[0m"

echo -e "\n\e[1;32mSleeping for $SLEEP_TIME seconds...\e[0m"  
sleep $SLEEP_TIME

echo -e "\n\e[1;33m5. Read - $FILE_NAME" 
echo -e "Started at `date +%H:%M:%S`\e[0m"  
echo dd bs=$BLOCK_SIZE of=/dev/null if=$FILE_NAME conv=fdatasync
dd bs=$BLOCK_SIZE of=/dev/null if=$FILE_NAME
echo -e "\e[1;33mFinished at `date +%H:%M:%S`\e[0m"

rm -f $FILE_NAME
wait
echo -e "\n\e[1;32mDone!\e[0m"
exit 0




