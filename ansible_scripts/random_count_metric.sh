#/bin/bash
# random_count_metric.sh

# Check arguments
if [ "$#" -ne 5 ]; then
  echo -e " Usage: $0 <Number of metrics> <Number of times> <Period in Sec> <Offset in Sec> <Value Range>"
  echo -e "   e.g: $0 3 10 60 5 20\n"

  exit 1
fi

NUM_METRICS=$1
COUNT=$2
PERIOD=$3
OFFSET=$4
RANGE=$5
CLTD_IP="10.0.0.10"
CLTD_PORT="2003"
HOST=`hostname`

echo -e "\n\e[1;33mStarted at `date`\e[0m\n"
c_num=0
for c in `seq 1 $COUNT`; do
  (( c_num ++ ))
    
  m_num=0
  for m in `seq 1 $NUM_METRICS`; do
   (( m_num ++ ))
   metric_val=`echo $RANDOM % $RANGE + 1 | bc`  
   echo -e \nmetric-$m_num.$c_num $metric_val
   #echo "test.$HOST-m-$m_num $metric_val `date +%s`" "| nc"  $CLTD_IP $CLTD_PORT
   echo test.$HOST-m-$m_num $metric_val `date +%s` | nc  $CLTD_IP $CLTD_PORT
   sleep $OFFSET 

  done
  sleep $PERIOD 

done 
echo -e "\n\e[1;33mFinished at `date`\e[0m"
echo -e "\n\e[1;32mDone!\e[0m"

