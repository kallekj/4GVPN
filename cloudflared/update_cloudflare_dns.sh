#!/bin/bash

printf "%s" "waiting for internet connection..."
while ! ping -c 1 -n -w 1 1.1.1.1 &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "Internet connection is online!"

ipadr=`ip -4 addr show wwan0 | grep inet | awk '{print $2}' | awk -F "/" '{print $1}'`

curl -X PUT "https://api.cloudflare.com/client/v4/zones/ZONE-ID/dns_records/RECORD-ID" \
     -H "Authorization: Bearer API-KEY" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"test.example.com","content":"'${ipadr}'","ttl":1,"proxied":false}'

echo ""
echo "DNS Record: test.example.com, has been updated with new ip. \nNew ip: '${ipadr}'" 
