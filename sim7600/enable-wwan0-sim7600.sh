#!/bin/bash

/usr/sbin/ifconfig wwan0 down

for _ in $(seq 1 10); do /usr/bin/test -c /dev/cdc-wdm0 && break; /bin/sleep 1; done

for _ in $(seq 1 10); do /usr/bin/qmicli -d /dev/cdc-wdm0 --nas-get-signal-strength && break; /bin/sleep 1; done

/usr/local/bin/qmi-network-raw /dev/cdc-wdm0 start 

/usr/sbin/udhcpc -i wwan0
