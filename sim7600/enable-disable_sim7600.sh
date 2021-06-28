#!/bin/bash
if [ ! -e /sys/class/gpio/gpio6 ]; then
    echo "File exists."
    echo "6" > /sys/class/gpio/export
fi
echo "out" > /sys/class/gpio/gpio6/direction
echo "0" > /sys/class/gpio/gpio6/value
sleep 2
echo "1" > /sys/class/gpio/gpio6/value
