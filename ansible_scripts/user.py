#!/usr/bin/python
# user.py
# This script creates GB Linux accounts 


__author__ = "Alex M"
__copyright__ = "Copyright 2014, Glassbeam Inc"
__credits__ = ["Alex Mogilevski"]
__license__ = ""
__maintainer__ = "Alex M"
__contact__ = "alex@glassbeam.com"
__state__ = "Development"
__date__ = "12-05-2014"
__version__ = "0.5"


import sys
import argparse
import ConfigParser
import boto.ec2
import ast
import traceback
import time
import re
import ansible.runner


USER_LIST = '/etc/passwd'
GROUP_LIST = '/etc/group'
BASTION = 'ssh_gateway'
ADMIN_USER = 'gbs'


# color output
class bc:
  HEADER = '\033[95m'
  BLUE = '\033[94m'
  GREEN = '\033[92m'
  YELLOW = '\033[93m'
  RED = '\033[91m'
  ENDC = '\033[0m'


def check_id(pattern, list):
  user_id_not_ok = False

  if pattern == '':
    print bc.RED + "User ID shouldn't be empty" + bc.ENDC
    user_id_not_ok = True

  else:
    pattern_2 = pattern.strip() + ":"

    for record in open(list, 'r'):
      search_account = re.match(pattern_2, record)

      if search_account:
        print pattern.strip() + bc.RED + " User ID already exists" + bc.ENDC
      
        user_id_not_ok = True

  return user_id_not_ok



def check_group(pattern, list):
  group_exists = False  
  pattern_2 = pattern.strip() + ":"

  for record in open(list, 'r'):
    search_account = re.match(pattern_2, record)

    if search_account:
      #print pattern.strip() + bc.GREEN + ' Group is OK' + bc.ENDC
      group_exists = True

  if group_exists == False:
    print pattern.strip() + bc.RED + ' Group doesn\'t exist' + bc.ENDC
    group_exists = False

  return group_exists


# I'm here!!!
def main():

 
  # check User ID
  user_id = raw_input(bc.YELLOW + '\nPlease enter User ID: ' + bc.ENDC)
  print bc.BLUE + '\nChecking: ' + bc.ENDC + USER_LIST + '\n'

  user_id_not_ok = True
  while user_id_not_ok:

    user_id_not_ok = check_id(user_id, USER_LIST) 
    if user_id_not_ok:
      user_id = raw_input(bc.YELLOW + '\nPlease try another User ID: ' + bc.ENDC)

  #print '\n' + user_id + bc.GREEN + ' User ID is available' + bc.ENDC
  

  # check Groups
  # e.g: Please try another Group IDs: test1 test2 
  groups = raw_input(bc.YELLOW + '\nPlease enter Group IDs: ' + bc.ENDC).split(" ")
  print bc.BLUE + '\nChecking: ' + bc.ENDC + GROUP_LIST + '\n'

  group_ids_ok = False
  while group_ids_ok == False:
    groups_list = []

    for group in groups:
      account = check_group(group, GROUP_LIST)
 
      if account:
        groups_list.append(group.strip())
        group_ids_ok = True

      else:
        group_ids_ok = False
        break 
         
    if group_ids_ok == False:
        groups = raw_input(bc.YELLOW + \
                 '\nPlease try another Group IDs: ' + bc.ENDC).split(" ")
 
  #print bc.GREEN + '\nGroup IDs are OK: ' + bc.ENDC + str(groups_list)  

  # check email
  email = raw_input(bc.YELLOW + '\nPlease enter Email address: ' + bc.ENDC)

  email_invalid = True
  while email_invalid:
    if not re.match("[^@]+@[^@]+\.[^@]+", email):

      print '\n' + email + bc.RED + ' Email is invalid' + bc.ENDC
      email = raw_input(bc.YELLOW + '\nPlease try again: ' + bc.ENDC)

    else:
      email_invalid = False
      #print bc.GREEN + '\nEmail is OK: ' + bc.ENDC + email

  # check if user is usr_type 
  print bc.GREEN + "\n\nFollowing account types are available:\n "
  print bc.YELLOW + " 1 - Employee\n 2 - Contractor\n 3 - Customer\n 4 - System User" 
  usr_type = raw_input('\nPlease choose (1, 2, 3 or 4): ' + bc.ENDC)

  type_invalid = True
  while type_invalid:  
    if usr_type in ('1'):
      user_type = 'GB_Employee_'
      user_info = user_type + email
      type_invalid = False

    elif usr_type in ('2'):    
      user_type = 'Contactor_'
      user_info = user_type + email
      type_invalid = False

    elif usr_type in ('3'):    
      user_type = 'Customer_'
      user_info = user_type + email
      type_invalid = False

    elif usr_type in ('4'):    
      user_type = 'GB_System_User_'
      user_info = user_type + email
      type_invalid = False

    else: 
      usr_type = raw_input(bc.RED + '\nPlease choose (1, 2, 3 or 4): ' + bc.ENDC)

  #print bc.GREEN + '\nUser Info: ' + bc.ENDC + user_info

  # SSH key  
  ssh_key = raw_input(bc.YELLOW + '\nPlease copy and paste public SSH key: ' + bc.ENDC)

  key_invalid = True
  while key_invalid:
    if len(ssh_key) < 300:
      print bc.RED + '\nThe key is too short' + bc.ENDC
      ssh_key = raw_input(bc.YELLOW + '\nPlease try again: ' + bc.ENDC)   

    else:
      key_invalid = False
        
  groups_str = ",".join(groups_list)

  print bc.YELLOW + "\n\nPlease check all parameters:"
  print bc.GREEN + '\nUser ID: ' + bc.ENDC + user_id
  print bc.GREEN + '\nGroup IDs: ' + bc.ENDC + groups_str
  print bc.GREEN + '\nUser Info: ' + bc.ENDC + user_info
  print bc.GREEN + '\nPublic SSH key: ' + bc.ENDC + '...' + ssh_key[-40:]

  confirm = raw_input(bc.YELLOW + '\nPlease confirm (yes/no): ' + bc.ENDC)
 
  if confirm != 'yes': 
    print bc.YELLOW + "\n Please start again" + bc.ENDC 
    exit(1)
  
  # construct the ansible runner and execute on all hosts
  accounts = ansible.runner.Runner(
    pattern=BASTION,
    forks=5,
    remote_user=ADMIN_USER,
    sudo='yes',
    module_name='user',
    module_args='name=%s comment=%s groups=%s append=yes' \
              % (user_id, user_info, groups_str)
  ).run()

  if accounts is None:
    print bc.RED + '\nError: ' + bc.ENDC + 'No hosts found' 
    sys.exit(1)

  print bc.GREEN + '\nFollowing accounts have been created:' + bc.ENDC
  for (hostname, account) in accounts['contacted'].items():
    #print account
    if not 'failed' in account:
      print "%s@%s" % (account['name'], hostname)


  # place SSH files 
  key_path='/home/%s/.ssh/authorized_keys' % user_id
  file_perm='0600'
  ssh_key_str=ssh_key.replace(" ","\ ")
  files = ansible.runner.Runner(
    pattern=BASTION,
    forks=5,
    remote_user=ADMIN_USER,
    sudo='yes',
    module_name='lineinfile',
    module_args='dest=%s line=%s owner=%s group=%s mode=%s create=yes state=present' \
              % (key_path, ssh_key_str, user_id, user_id, file_perm)
  ).run()

  if files is None:
    print bc.RED + '\nError: ' + bc.ENDC + 'No hosts found'
    sys.exit(1)

  #print bc.GREEN + '\nPublic SSH key has been placed on:' + bc.ENDC
  #for (hostname, file) in files['contacted'].items():
    #print file
    #if not 'failed' in file:
      #print "%s" % (hostname)

  # change owner and perimissions of .ssh directory
  dir_path='/home/%s/.ssh' % user_id
  dir_perm='0700'
  files = ansible.runner.Runner(
    pattern=BASTION,
    forks=5,
    remote_user=ADMIN_USER,
    sudo='yes',
    module_name='file',
    module_args='path=%s  owner=%s group=%s mode=%s state=directory' \
              % (dir_path, user_id, user_id, dir_perm)
  ).run()

  if files is None:
    print bc.RED + '\nError: ' + bc.ENDC + 'No hosts found'
    sys.exit(1)

  #print bc.GREEN + '\n.ssh directory permissions has been changed' + bc.ENDC
  #for (hostname, file) in files['contacted'].items():
    #print file
    #if not 'failed' in file:
      #print "%s" % (hostname)

  # email body
  rcp_name = raw_input(bc.YELLOW + '\nPlease enter recipient name: ' + bc.ENDC)
  print "\n%s," % rcp_name
  print "\nYour account has been created on all bastion hosts:"
  print "\nUser ID: %s" % user_id
  print "Environment: %s" % groups[0][-3:]
  print "\nPlease follow steps #3 and #4 to configure your local SSH settings:"
  print "https://sites.google.com/site/glassbeamwiki/aws-infrastructure/ssh-login"  

if __name__ == '__main__':
  main()

# EOF
