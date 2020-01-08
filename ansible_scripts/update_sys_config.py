#!/usr/bin/python
#
__author__ = "Alex M"
__copyright__ = "Copyright 2014, Glassbeam Inc"
__credits__ = ["Alex Mogilevski"]
__license__ = ""
__maintainer__ = "Alex M"
__contact__ = "alex@glassbeam.com"
__status__ = "Development"
__date__ = "10-10-2014"
__version__ = "1.2"


import sys
import argparse
import shutil
import re
import ConfigParser
#import boto.ec2
#import ast
#import traceback
#import time

# argument parsing  
parser = argparse.ArgumentParser(description='EC2 launch instance')
parser.add_argument('-i','--init_path', help='INI File Path', required=True)
args = parser.parse_args()

# read .ini file
init = ConfigParser.RawConfigParser()
init.read(args.init_path)

# system parameters
SYS_USER = init.get('system', 'ENVIRONMENT')
ADMIN_USER = init.get('system', 'ADMIN_USER')
PRODUCTION = init.get('system', 'PRODUCTION')
DNS_ZONE_FILE = init.get('system', 'DNS_ZONE')
BASE_DIR = init.get('system', 'BASE_DIR')

SYS_ORIG_CONF_PATH = '%s/%s/current/.ssh/config' %(BASE_DIR, SYS_USER)
ADMIN_ORIG_CONF_PATH = '%s/%s/current/.ssh/config' %(BASE_DIR, ADMIN_USER)
ANSIBLE_ORIG_CONF_PATH = '%s/wide/current/ansible/hosts' %(BASE_DIR)
HOSTS_ORIG_CONF_PATH = '%s/wide/current/etc/hosts' %(BASE_DIR)
DNS_ORIG_CONF_PATH = '%s/wide/current/dns/%s' %(BASE_DIR, DNS_ZONE_FILE)

SYS_CONF_PATH = '%s/%s/pickup/.ssh/config' %(BASE_DIR, SYS_USER)
ADMIN_CONF_PATH = '%s/%s/pickup/.ssh/config' %(BASE_DIR, ADMIN_USER)
ANSIBLE_CONF_PATH = '%s/wide/pickup/ansible/hosts' %(BASE_DIR)
HOSTS_CONF_PATH = '%s/wide/pickup/etc/hosts' %(BASE_DIR)
DNS_CONF_PATH = '%s/wide/pickup/dns/%s' %(BASE_DIR, DNS_ZONE_FILE)


# TODO: services
HOSTS = 'HOSTS'
DNS = 'DNS'
ANSIBLE = 'ANSIBLE'
SYS_SSH = 'SYS_SSH'
ADMIN_SSH = 'ADMIN_SSH'


# color output
class bc:
  HEADER = '\033[95m'
  OKBLUE = '\033[94m'
  OKGREEN = '\033[92m'
  WARNING = '\033[93m'
  FAIL = '\033[91m'
  ENDC = '\033[0m'


def create_list_from_file(path, list):
  file = open(path, 'rU')
  
  for line in file:
    list.append(line.strip())
    
  file.close() 


def create_host_name_list(ssh_list, host_name_list):
  for count in xrange(len(ssh_list)):
    host_name = "%s-%s" %(SYS_USER, ssh_list[count])
    host_name_list.append(host_name)


def write_to_file(path, list, service):
  write_msg = '\nWriting: '
  warn_msg = '\nDuplication warning! Skipping: '

  print bc.OKBLUE + "\n\nChecking " + bc.ENDC + "%s" %(path)

  for count in xrange(len(list)):
    ip_address = list[count][0]
    host_name = list[count][1]

  # TODO - check how to scan file multiple times 
    if host_name in open(path).read():
      print bc.WARNING + warn_msg + bc.ENDC + "%s" %(host_name)

    elif ip_address in open(path).read():
      print bc.WARNING + warn_msg + bc.ENDC + "%s" %(ip_address)

    else:
      if service is HOSTS:
        file = open(path, 'a+')
        record = "\n%s       %s" %(ip_address, host_name)

      elif service is DNS:
        file = open(path, 'a+')
        record = "\n%s               IN      A               %s" \
               %(host_name, ip_address)
    
      elif service is ANSIBLE:
        file = open(path, 'a+')
        if (SYS_USER == PRODUCTION):
          #ssh_name = host_name[4:]
          ssh_name = host_name
        else:
          ssh_name = host_name
        record = "\n%s" %ssh_name       
            
      elif service is SYS_SSH:
        file = open(path, 'a+')
        user = SYS_USER
        ssh_name = host_name[4:]

        key_str = "   IdentityFile ~/.ssh/key.pem"    
        record = "\n\nHost %s\n   User %s\n   HostName %s\n" \
                 %(ssh_name, user, host_name) + key_str

      elif service is ADMIN_SSH:
        file = open(path, 'a+')
        user = ADMIN_USER
        if (SYS_USER == PRODUCTION):   
          ssh_name = host_name[4:]
        else:
          ssh_name = host_name
        key_str = "   IdentityFile ~/.ssh/key.pem"    
        record = "\n\nHost %s\n   User %s\n   HostName %s\n" \
                 %(ssh_name, user, host_name) + key_str

      file.write(record)
      file.close
      print bc.OKGREEN + write_msg + bc.ENDC + "%s" %(record)


  # change DNS Serial number 
  if service is DNS:
    file = open(path, 'r')
    for line in file: 
      line = line.rstrip()
      if re.search('Serial', line):
        serial_line = line
        serial = serial_line.partition(' ')[0]
        new_serial = "			" + str(int(serial) + 2)
    file.close
  
    file_data = open(path).read()
    if serial in file_data:
      file_data = file_data.replace(serial, new_serial)
      file_write = open(path, 'w')
      file_write.write(file_data)
      file_write.flush()
      file_write.close()

    print bc.OKGREEN + \
          "\n\nDNS Zone Serial change:\n" + \
          bc.ENDC + \
          "\nold - " + serial.strip() + "\nnew - " + new_serial.strip()


def main():

  print bc.OKBLUE + "\nCopying current " + bc.ENDC + \
      "%s" %(ADMIN_ORIG_CONF_PATH)
  shutil.copyfile(ADMIN_ORIG_CONF_PATH, ADMIN_CONF_PATH)

  print bc.OKBLUE + "\nCopying current " + bc.ENDC + \
      "%s" %(SYS_ORIG_CONF_PATH)
  shutil.copyfile(SYS_ORIG_CONF_PATH, SYS_CONF_PATH)

  print bc.OKBLUE + "\nCopying current " + bc.ENDC + \
      "%s" %(HOSTS_ORIG_CONF_PATH)
  shutil.copyfile(HOSTS_ORIG_CONF_PATH, HOSTS_CONF_PATH)

  print bc.OKBLUE + "\nCopying current " + bc.ENDC + \
     "%s" %(DNS_ORIG_CONF_PATH)
  shutil.copyfile(DNS_ORIG_CONF_PATH, DNS_CONF_PATH)

  print bc.OKBLUE + "\nCopying current " + bc.ENDC + \
     "%s" %(ANSIBLE_ORIG_CONF_PATH)
  shutil.copyfile(ANSIBLE_ORIG_CONF_PATH, ANSIBLE_CONF_PATH)

  # create empty containers
  ip_list = []
  host_name_list = []
  combined_list = []
  ssh_name_list = []

  # create IP list
  create_list_from_file(args.ip_list_path, ip_list)

  # create SSH name list
  create_list_from_file(args.ssh_list_path, ssh_name_list)

  # create host name list
  create_host_name_list(ssh_name_list, host_name_list)

  # create combined list
  combined_list = zip(ip_list, host_name_list)

  # write to System User SSH  host file
  write_to_file(ADMIN_CONF_PATH, combined_list, ADMIN_SSH)

  # write to Admin User SSH file
  write_to_file(SYS_CONF_PATH, combined_list, SYS_SSH)

  # write to Ansible host file
  write_to_file(ANSIBLE_CONF_PATH, combined_list, ANSIBLE)
    
  # write to Hosts file
  write_to_file(HOSTS_CONF_PATH, combined_list, HOSTS)
 
  # write to DNS Zone file
  write_to_file(DNS_CONF_PATH, combined_list, DNS)
  

if __name__ == '__main__':
  main()
# EOF
