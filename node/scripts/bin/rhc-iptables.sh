#!/bin/bash

#
# Create iptables rules for application compartmentalization.
#

UID_BEGIN=500
UID_END=12700

DEBUG=""
SYSCONFIG=""


function iptables {
  if [ "${SYSCONFIG}" ]; then
    echo "$@"
  elif [ "${DEBUG}" ]; then
    echo /sbin/iptables "$@"
  else
    /sbin/iptables "$@"
  fi
}

function new_table {
  if [ "${SYSCONFIG}" ]; then
    echo ':'"$1"' REJECT [0:0]'
  else
    iptables -N "$1"
    iptables -F "$1"
    iptables -P "$1" REJECT
  fi
}


function help {
  echo "Usage: $0 [ -n ] [ -s ]" >&2
  echo "    -n   Print what would be done." >&2
  echo "    -s   Print output suitable for /etc/sysconfig/iptables." >&2
}

while getopts ':hns' opt; do
  case $opt in
    'h')
      help
      exit 0
      ;;
    'n')
      DEBUG=1
      ;;
    's')
      SYSCONFIG=1
      ;;
    '?')
      echo "Invalid option: -$OPTARG"
      help
      exit 1
      ;;
  esac
done



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
new_table rhc-app-table

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
