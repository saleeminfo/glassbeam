#!/bin/bash
# from here: http://www.codingsteps.com/install-redis-2-6-on-amazon-ec2-linux-ami-or-centos/
# and here: https://raw.github.com/gist/257849/9f1e627e0b7dbe68882fa2b7bdb1b2b263522004/redis-server
###############################################
# To use: 
# <<!!!!!!!!!!!!!!!!!!! FIX ME !!!!!!!!!!!!!!!!!!!!!!!!> wget https://raw.github.com/gist/2776679/04ca3bbb9f085b192f6aca945120fe12d59f15f9/install-redis.sh
# chmod 777 install-redis.sh
# ./install-redis.sh
###############################################
echo "*****************************************"
echo " 1. Prerequisites: Install updates, set time zones, install GCC and make"
echo "*****************************************"
#sudo yum -y update
#sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles \/etc/localtime
#sudo yum -y install gcc gcc-c++ make 
echo "*****************************************"
echo " 2. Download, Untar and Make Redis 2.6"
echo "*****************************************"
cd /usr/local/src
sudo wget http://download.redis.io/releases/redis-2.6.16.tar.gz
sudo tar xzf redis-2.6.16.tar.gz
sudo rm redis-2.6.16.tar.gz -f
cd redis-2.6.16
sudo make distclean
sudo make
echo "*****************************************"
echo " 3. Create Directories and Copy Redis Files"
echo "*****************************************"
sudo mkdir /etc/redis /var/lib/redis
sudo cp src/redis-server src/redis-cli /usr/local/bin
echo "*****************************************"
echo " 4. Configure Redis.Conf"
echo "*****************************************"
echo " Edit redis.conf as follows:"
echo " 1: ... daemonize yes"
echo " 2: ... bind 127.0.0.1"
echo " 3: ... dir /var/lib/redis"
echo " 4: ... loglevel notice"
echo " 5: ... logfile /var/log/redis.log"
echo "*****************************************"
sudo sed -e "s/^daemonize no$/daemonize yes/" -e "s/^# bind 127.0.0.1$/bind 127.0.0.1/" -e "s/^dir \.\//dir \/var\/lib\/redis\//" -e "s/^loglevel verbose$/loglevel notice/" -e "s/^logfile stdout$/logfile \/var\/log\/redis.log/" redis.conf | sudo tee /etc/redis/redis.conf
echo "*****************************************"
echo " 5. Download init Script"
echo "*****************************************"
sudo wget https://raw.github.com/saxenap/install-redis-amazon-linux-centos/master/redis-server
echo "*****************************************"
echo " 6. Move and Configure Redis-Server"
echo "*****************************************"
sudo mv redis-server /etc/init.d
sudo chmod 755 /etc/init.d/redis-server
echo "*****************************************"
echo " 7. Auto-Enable Redis-Server"
echo "*****************************************"
sudo chkconfig --add redis-server
sudo chkconfig --level 345 redis-server on
echo "*****************************************"
echo " 8. Start Redis Server"
echo "*****************************************"
sudo service redis-server start
echo "*****************************************"
echo " Complete!"
echo " You can test your redis installation using the redis console:"
echo "   $ /usr/local/redis-2.6.16/src/redis-cli"
echo "   redis> set foo bar"
echo "   OK"
echo "   redis> get foo"
echo "   bar"
echo "*****************************************"
read -p "Press [Enter] to continue..."
