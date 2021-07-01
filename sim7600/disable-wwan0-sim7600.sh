#!/bin/bash

/usr/local/bin/qmi-network-raw /dev/cdc-wdm0 stop

/usr/sbin/ifconfig wwan0 down

