#!/bin/bash

#
# Create iptables rules for application compartmentalization.
#

UID_BEGIN=500
UID_END=12700

# Bottom block is system services, quick bypass
iptables -A OUTPUT -o lo -d 127.0.0.0/25 \
  -m owner --uid-owner ${UID_BEGIN}-${UID_END} \
  -j ACCEPT


# Established connections quickly bypass
iptables -A OUTPUT -o lo -d 127.0.0.0/8 \
  -m owner --uid-owner ${UID_BEGIN}-${UID_END} \
  -m state --state ESTABLISHED,RELATED \
  -j ACCEPT


# New connections with specific uids get checked on the app table.
iptables -N rhc-app-table
iptables -F rhc-app-table
iptables -P rhc-app-table REJECT

iptables -A OUTPUT -o lo -d 127.0.0.0/8 \
  -m owner --uid-owner ${UID_BEGIN}-${UID_END} \
  -m state --state NEW \
  -j rhc-app-table

seq ${UID_BEGIN} ${UID_END} | while read uid; do
  # Logic copied from rhc-ip-prep
  a=$(($uid*128+2130706432))
  net=$(($a>>24 )).$(($(($a%16777216))<<8>>24)).$(($(($a%65536))<<16>>24)).$(($(($a%256))<<24>>24))

  iptables -A rhc-app-table -d ${net}/25 -m owner --uid-owner $uid -j ACCEPT 
done
