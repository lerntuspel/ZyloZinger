#!/bin/sh
######################################
# Run this script on DE1 upon startup
######################################
mount /dev/mmcblk0p1 /mnt
#Set rows and columns for terminal
echo stty rows 70
echo stty cols 140

#connect to ethernet
ifup eth0


