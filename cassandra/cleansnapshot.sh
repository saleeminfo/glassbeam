#echo "Cassandra Hostname to clean up"
#read chost
echo "Current Disk Usage"
df -h /ebs

echo "Following Snapshots are occupying more space"
~/cassandra/current/bin/nodetool listsnapshots | awk '{print $1" "$5" "$6}' | grep GB

echo "Type the Snapshot Table name you want to clean. eg:1475830562618-event_tbl"
read tname
echo "Type the Keyspace Name. eg:didata_didata_podv1"
read kname
~/cassandra/current/bin/nodetool clearsnapshot -t $tname -- $kname

echo "Disk Usage after cleanup"
df -h /ebs

