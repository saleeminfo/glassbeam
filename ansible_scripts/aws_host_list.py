#!/usr/bin/python
# aws_host_list.py
#
#

__author__ = "Alex M"
__copyright__ = "Copyright 2014, Glassbeam Inc"
__credits__ = ["Alex Mogilevski"]
__license__ = ""
__maintainer__ = "Alex M"
__contact__ = "alex@glassbeam.com"
__status__ = "Development"
__date__ = "02-7-2015"
__version__ = "0.1"

import argparse
import subprocess
import StringIO

# argument parsing  
parser = argparse.ArgumentParser(description='Create AWS Hostname List in .ini format')
parser.add_argument('-p','--pattern', help='Hostname Pattern, e.g: gbp-cass-*')
parser.add_argument('-s','--section', help='Section Header, e.g: monitoring')
parser.add_argument('-f','--file', help='Output File, e.g: /tmp/list.txt')
args = parser.parse_args()

# AWS CLI command
cmd = "aws ec2 describe-instances --filters 'Name=tag-value,Values=%s' --query 'Reservations[*].Instances[*].{Hostname:Tags[0].Value, IP:NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress}' --output text" % (args.pattern)

# Run subprocess and redirect output in pipe 
pipe = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
output = pipe.communicate()[0].replace("\t",": ")

# Write output to the string
stringIO = StringIO.StringIO()
stringIO.write(output)
content = stringIO.getvalue()

# Write string to the file
file = open(args.file, "wb")
file.write("[" + args.section + "]\n")
file.write(content)
file.close

print "\n[" + args.section + "]"
print content

