#!/bin/bash

#read -p " Image Type? linux/windows/vertica : " imgtype
imgtype="linux"
read -p " Server Name? dd-gbd-lcp-01 : " servername
read -p " Server IP? 10.163.36.x/10.172.93.x/10.172.137.x : " serverip

unset username
unset password
echo -n "DD Cloud UserName : "
read username
prompt="password:"
while IFS= read -p "$prompt" -r -s -n 1 char
do
    if [[ $char == $'\0' ]]
    then
         break
    fi
    prompt='*'
    password+="$char"

done

if [ $imgtype = linux ]; then
curl -u  $username:$password https://api-na.dimensiondata.com/oec/2.2/b0f9e6d7-d477-47f3-bc6b-1605747b345c/server/deployServer --header "Content-Type: application/json" --data '{

    "name": "",
    "description": "Created on 30-Dec-2019 by Saleem - DiData IS for LB",
    "imageId": "585d85b7-454a-44a0-a0bb-d942e851791d",
    "start": true,
    "cpu": {
        "count": 4,
        "coresPerSocket": 1,
        "speed": "STANDARD"
    },
    "memoryGb": 4,
    "primaryDns": "10.20.255.12",
    "secondaryDns": "10.20.255.13",
    "networkInfo": {
        "networkDomainId": "95b0e451-b20d-4934-b5a0-7409be40ad73",
        "primaryNic": [
            {
                "privateIpv4": ""
            }

        ]
    }
}'


fi
